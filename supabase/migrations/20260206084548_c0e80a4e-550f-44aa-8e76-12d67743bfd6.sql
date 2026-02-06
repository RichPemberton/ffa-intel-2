-- =====================================================
-- FFA Intelligence Database Schema - Consolidated Migration
-- =====================================================

-- Part 1: Core Enum Types
-- =====================================================

CREATE TYPE public.user_role AS ENUM ('buyer', 'innovator', 'partner', 'investor', 'ecosystem');
CREATE TYPE public.sector_type AS ENUM ('apparel', 'luxury', 'sportswear', 'footwear', 'accessories');
CREATE TYPE public.maturity_level AS ENUM ('early', 'mid', 'advanced');
CREATE TYPE public.follow_target_type AS ENUM ('assembly', 'signal', 'innovator');
CREATE TYPE public.action_type AS ENUM ('view', 'follow', 'join', 'pilot_request', 'connection_request', 'brief_request');
CREATE TYPE public.app_role AS ENUM ('admin', 'super_admin');
CREATE TYPE public.programme_type AS ENUM ('concierge', 'accelerator', 'thematic', 'cohort');
CREATE TYPE public.programme_status AS ENUM ('draft', 'active', 'paused', 'completed', 'archived');
CREATE TYPE public.programme_stage AS ENUM ('discover', 'source', 'assemble', 'co-design', 'orchestrate', 'activate');
CREATE TYPE public.programme_member_role AS ENUM ('client', 'ffa_team', 'observer');
CREATE TYPE public.feedback_response AS ENUM ('save', 'interested', 'maybe', 'not_now', 'not_relevant');
CREATE TYPE public.connection_context AS ENUM ('organisation', 'assembly', 'programme', 'concierge', 'direct');
CREATE TYPE public.connection_status AS ENUM ('pending', 'approved', 'rejected', 'blocked');
CREATE TYPE public.subscription_tier AS ENUM ('free', 'starter', 'pro', 'enterprise');

-- =====================================================
-- Part 2: Core Utility Function
-- =====================================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- =====================================================
-- Part 3: User Roles Table (Secure - Separate from Profiles)
-- =====================================================

CREATE TABLE public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role app_role NOT NULL,
  granted_by uuid REFERENCES auth.users(id),
  granted_at timestamp with time zone DEFAULT now(),
  UNIQUE (user_id, role)
);

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Security definer functions for role checking
CREATE OR REPLACE FUNCTION public.has_role(_user_id uuid, _role app_role)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  )
$$;

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = auth.uid()
      AND role = 'super_admin'
  )
$$;

-- RLS policies for user_roles
CREATE POLICY "Super admins can view all roles"
ON public.user_roles FOR SELECT
USING (public.is_super_admin() OR user_id = auth.uid());

CREATE POLICY "Super admins can manage roles"
ON public.user_roles FOR ALL
USING (public.is_super_admin());

-- =====================================================
-- Part 4: Profiles Table
-- =====================================================

CREATE TABLE public.profiles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  display_name TEXT,
  organisation_name TEXT,
  role user_role NOT NULL DEFAULT 'buyer',
  sectors sector_type[] DEFAULT '{}',
  challenges TEXT[] DEFAULT '{}',
  maturity_level maturity_level DEFAULT 'mid',
  engagement_score INTEGER DEFAULT 0,
  contribution_score INTEGER DEFAULT 0,
  onboarding_completed BOOLEAN DEFAULT false,
  is_admin BOOLEAN NOT NULL DEFAULT false,
  website_url TEXT,
  ai_suggested_sectors TEXT[],
  ai_suggested_challenges TEXT[],
  website_scraped_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = user_id);

CREATE INDEX idx_profiles_user_id ON public.profiles(user_id);
CREATE INDEX idx_profiles_is_admin ON public.profiles(is_admin) WHERE is_admin = true;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (user_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- Part 5: Follows & User Actions
-- =====================================================

CREATE TABLE public.follows (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  target_type follow_target_type NOT NULL,
  target_id TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id, target_type, target_id)
);

ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own follows"
  ON public.follows FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own follows"
  ON public.follows FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete their own follows"
  ON public.follows FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX idx_follows_user_id ON public.follows(user_id);
CREATE INDEX idx_follows_target ON public.follows(target_type, target_id);

CREATE TABLE public.user_actions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  action_type action_type NOT NULL,
  target_type TEXT NOT NULL,
  target_id TEXT NOT NULL,
  target_name TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.user_actions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own actions"
  ON public.user_actions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own actions"
  ON public.user_actions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE INDEX idx_user_actions_user_id ON public.user_actions(user_id);
CREATE INDEX idx_user_actions_created_at ON public.user_actions(created_at DESC);

-- Trigger to update scores based on actions
CREATE OR REPLACE FUNCTION public.update_user_scores()
RETURNS TRIGGER AS $$
DECLARE
  engagement_points INT := 0;
  contribution_points INT := 0;
BEGIN
  CASE NEW.action_type
    WHEN 'view' THEN engagement_points := 1;
    WHEN 'follow' THEN engagement_points := 3;
    WHEN 'join' THEN contribution_points := 5;
    WHEN 'pilot_request' THEN contribution_points := 10;
    WHEN 'connection_request' THEN contribution_points := 5;
    WHEN 'brief_request' THEN contribution_points := 5;
    ELSE NULL;
  END CASE;

  UPDATE public.profiles
  SET
    engagement_score = COALESCE(engagement_score, 0) + engagement_points,
    contribution_score = COALESCE(contribution_score, 0) + contribution_points,
    updated_at = now()
  WHERE user_id = NEW.user_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER on_user_action_update_scores
  AFTER INSERT ON public.user_actions
  FOR EACH ROW
  EXECUTE FUNCTION public.update_user_scores();

-- =====================================================
-- Part 6: Email Preferences
-- =====================================================

CREATE TABLE public.email_preferences (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL UNIQUE,
  email TEXT NOT NULL,
  notifications_enabled BOOLEAN DEFAULT true,
  signal_updates BOOLEAN DEFAULT true,
  assembly_updates BOOLEAN DEFAULT true,
  weekly_digest BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.email_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own preferences"
  ON public.email_preferences FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own preferences"
  ON public.email_preferences FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own preferences"
  ON public.email_preferences FOR UPDATE USING (auth.uid() = user_id);

CREATE TRIGGER update_email_preferences_updated_at
  BEFORE UPDATE ON public.email_preferences
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================
-- Part 7: Challenge Categories & Standard Challenges
-- =====================================================

CREATE TABLE public.challenge_categories (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.challenge_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view categories" ON public.challenge_categories FOR SELECT USING (true);
CREATE POLICY "Admins can insert categories" ON public.challenge_categories FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND is_admin = true));
CREATE POLICY "Admins can update categories" ON public.challenge_categories FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND is_admin = true));
CREATE POLICY "Admins can delete categories" ON public.challenge_categories FOR DELETE
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND is_admin = true));

CREATE TRIGGER update_challenge_categories_updated_at
  BEFORE UPDATE ON public.challenge_categories
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

INSERT INTO public.challenge_categories (name, description, display_order) VALUES
  ('Regulatory', 'Compliance, reporting, and regulatory requirements', 1),
  ('Sustainability', 'Environmental impact and circular economy', 2),
  ('Operations', 'Supply chain, logistics, and process optimization', 3),
  ('Technology', 'Digital transformation and tech adoption', 4),
  ('Organizational', 'Change management and stakeholder alignment', 5),
  ('Communication', 'Transparency and stakeholder engagement', 6),
  ('Custom', 'User-defined challenges', 99);

CREATE TABLE public.standard_challenges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text UNIQUE NOT NULL,
  name text NOT NULL,
  description text,
  category_id uuid REFERENCES public.challenge_categories(id) ON DELETE SET NULL,
  display_order integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.standard_challenges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view standard challenges" ON public.standard_challenges FOR SELECT USING (true);
CREATE POLICY "Admins can insert standard challenges" ON public.standard_challenges FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE profiles.user_id = auth.uid() AND profiles.is_admin = true));
CREATE POLICY "Admins can update standard challenges" ON public.standard_challenges FOR UPDATE
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.user_id = auth.uid() AND profiles.is_admin = true));
CREATE POLICY "Admins can delete standard challenges" ON public.standard_challenges FOR DELETE
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.user_id = auth.uid() AND profiles.is_admin = true));

CREATE TRIGGER update_standard_challenges_updated_at
  BEFORE UPDATE ON public.standard_challenges
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

INSERT INTO public.standard_challenges (slug, name, description, category_id, display_order) VALUES
  ('dpp', 'Digital Product Passport', 'EU compliance and data requirements',
    (SELECT id FROM challenge_categories WHERE name = 'Regulatory' LIMIT 1), 1),
  ('traceability', 'Traceability', 'Supply chain visibility and verification',
    (SELECT id FROM challenge_categories WHERE name = 'Operations' LIMIT 1), 2),
  ('circularity', 'Circularity', 'Resale, repair, recycling infrastructure',
    (SELECT id FROM challenge_categories WHERE name = 'Sustainability' LIMIT 1), 3),
  ('transparency', 'Transparency', 'Consumer and stakeholder communication',
    (SELECT id FROM challenge_categories WHERE name = 'Communication' LIMIT 1), 4),
  ('sustainability', 'Sustainability', 'Impact measurement and reduction',
    (SELECT id FROM challenge_categories WHERE name = 'Sustainability' LIMIT 1), 5),
  ('compliance', 'Regulatory Compliance', 'EPR, due diligence, reporting',
    (SELECT id FROM challenge_categories WHERE name = 'Regulatory' LIMIT 1), 6),
  ('returns', 'Returns & Waste', 'Reducing product returns and waste',
    (SELECT id FROM challenge_categories WHERE name = 'Operations' LIMIT 1), 7),
  ('supply-chain', 'Supply Chain', 'Optimization and resilience',
    (SELECT id FROM challenge_categories WHERE name = 'Operations' LIMIT 1), 8);

-- Custom challenges
CREATE TABLE public.custom_challenges (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  created_by UUID NOT NULL,
  scope TEXT NOT NULL DEFAULT 'personal' CHECK (scope IN ('personal', 'assembly', 'global')),
  assembly_id UUID,
  is_approved BOOLEAN DEFAULT false,
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.custom_challenges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view accessible custom challenges" ON public.custom_challenges FOR SELECT
  USING (created_by = auth.uid() OR (scope = 'global' AND is_approved = true) OR (scope = 'assembly'));
CREATE POLICY "Users can create custom challenges" ON public.custom_challenges FOR INSERT
  WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Users can update their own challenges" ON public.custom_challenges FOR UPDATE
  USING (auth.uid() = created_by AND scope != 'global');
CREATE POLICY "Users can delete their own challenges" ON public.custom_challenges FOR DELETE
  USING (auth.uid() = created_by AND scope != 'global');

CREATE TRIGGER update_custom_challenges_updated_at
  BEFORE UPDATE ON public.custom_challenges
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================
-- Part 8: Assembly Proposals
-- =====================================================

CREATE TABLE public.assembly_proposals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  name TEXT NOT NULL,
  problem_statement TEXT NOT NULL,
  primary_challenge TEXT NOT NULL,
  sectors TEXT[] NOT NULL DEFAULT '{}',
  components JSONB NOT NULL DEFAULT '[]',
  buyer_use_cases TEXT[] NOT NULL DEFAULT '{}',
  target_participants INTEGER NOT NULL DEFAULT 5,
  kpis TEXT[] NOT NULL DEFAULT '{}',
  timeline TEXT NOT NULL,
  expected_maturity TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'active')),
  visibility TEXT NOT NULL DEFAULT 'public' CHECK (visibility IN ('public', 'private')),
  access_model TEXT DEFAULT 'open' CHECK (access_model IN ('open', 'invite_only', 'application', 'link_based')),
  share_token TEXT UNIQUE,
  requires_premium BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.assembly_proposals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own proposals" ON public.assembly_proposals FOR SELECT
  USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own proposals" ON public.assembly_proposals FOR INSERT
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own pending proposals" ON public.assembly_proposals FOR UPDATE
  USING (auth.uid() = user_id AND status = 'pending');
CREATE POLICY "Admins can view all proposals" ON public.assembly_proposals FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE profiles.user_id = auth.uid() AND profiles.is_admin = true));
CREATE POLICY "Admins can update any proposal" ON public.assembly_proposals FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE profiles.user_id = auth.uid() AND profiles.is_admin = true));

CREATE TRIGGER update_assembly_proposals_updated_at
  BEFORE UPDATE ON public.assembly_proposals
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Assembly members
CREATE TABLE public.assembly_members (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  assembly_id UUID NOT NULL REFERENCES public.assembly_proposals(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member', 'pending', 'invited')),
  invited_by UUID,
  invitation_message TEXT,
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(assembly_id, user_id)
);

ALTER TABLE public.assembly_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Assembly owners can manage members" ON public.assembly_members FOR ALL
  USING (EXISTS (SELECT 1 FROM public.assembly_proposals ap WHERE ap.id = assembly_id AND ap.user_id = auth.uid()));
CREATE POLICY "Users can view their own membership" ON public.assembly_members FOR SELECT
  USING (user_id = auth.uid());

-- =====================================================
-- Part 9: Innovation Programs (Legacy)
-- =====================================================

CREATE TABLE public.innovation_programs (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'scoping' CHECK (status IN ('scoping', 'active', 'review', 'scaling', 'complete', 'paused')),
  buyer_id UUID REFERENCES auth.users(id),
  buyer_name TEXT NOT NULL,
  buyer_contact TEXT,
  innovator_id UUID REFERENCES auth.users(id),
  innovator_name TEXT NOT NULL,
  innovator_contact TEXT,
  assembly_id UUID,
  primary_challenge TEXT,
  sectors TEXT[] DEFAULT '{}',
  objectives TEXT[] DEFAULT '{}',
  start_date DATE,
  target_end_date DATE,
  milestones JSONB DEFAULT '[]',
  kpis JSONB DEFAULT '[]',
  next_action JSONB,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by UUID REFERENCES auth.users(id)
);

ALTER TABLE public.innovation_programs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view programs they participate in" ON public.innovation_programs FOR SELECT
  USING (auth.uid() = buyer_id OR auth.uid() = innovator_id OR auth.uid() = created_by OR
    EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND is_admin = true));
CREATE POLICY "Users can create programs" ON public.innovation_programs FOR INSERT
  WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Participants can update programs" ON public.innovation_programs FOR UPDATE
  USING (auth.uid() = buyer_id OR auth.uid() = innovator_id OR auth.uid() = created_by);

CREATE TRIGGER update_innovation_programs_updated_at
  BEFORE UPDATE ON public.innovation_programs
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Program messages
CREATE TABLE public.program_messages (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  program_id UUID NOT NULL REFERENCES public.innovation_programs(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users(id),
  sender_name TEXT NOT NULL,
  sender_role TEXT NOT NULL CHECK (sender_role IN ('buyer', 'innovator', 'admin')),
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'system', 'file')),
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.program_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Program participants can view messages" ON public.program_messages FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.innovation_programs p WHERE p.id = program_id
    AND (p.buyer_id = auth.uid() OR p.innovator_id = auth.uid() OR p.created_by = auth.uid())));
CREATE POLICY "Program participants can send messages" ON public.program_messages FOR INSERT
  WITH CHECK (auth.uid() = sender_id AND EXISTS (SELECT 1 FROM public.innovation_programs p
    WHERE p.id = program_id AND (p.buyer_id = auth.uid() OR p.innovator_id = auth.uid() OR p.created_by = auth.uid())));

-- Program documents
CREATE TABLE public.program_documents (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  program_id UUID NOT NULL REFERENCES public.innovation_programs(id) ON DELETE CASCADE,
  uploaded_by UUID NOT NULL REFERENCES auth.users(id),
  uploader_name TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_type TEXT,
  file_size INTEGER,
  description TEXT,
  category TEXT DEFAULT 'general' CHECK (category IN ('general', 'contract', 'report', 'presentation', 'data')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.program_documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Program participants can view documents" ON public.program_documents FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.innovation_programs p WHERE p.id = program_id
    AND (p.buyer_id = auth.uid() OR p.innovator_id = auth.uid() OR p.created_by = auth.uid())));
CREATE POLICY "Program participants can upload documents" ON public.program_documents FOR INSERT
  WITH CHECK (auth.uid() = uploaded_by AND EXISTS (SELECT 1 FROM public.innovation_programs p
    WHERE p.id = program_id AND (p.buyer_id = auth.uid() OR p.innovator_id = auth.uid() OR p.created_by = auth.uid())));
CREATE POLICY "Uploaders can delete their documents" ON public.program_documents FOR DELETE
  USING (auth.uid() = uploaded_by);

-- =====================================================
-- Part 10: Programmes (Concierge Phase 2)
-- =====================================================

CREATE TABLE public.programmes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type programme_type NOT NULL DEFAULT 'concierge',
  client_org_id UUID REFERENCES public.profiles(id),
  client_org_name TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  framework TEXT NOT NULL DEFAULT 'Path to Impact',
  start_date DATE,
  end_date DATE,
  status programme_status NOT NULL DEFAULT 'draft',
  seats_included INTEGER NOT NULL DEFAULT 5,
  seats_used INTEGER NOT NULL DEFAULT 0,
  join_code TEXT UNIQUE,
  ffa_owner_id UUID,
  created_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.programme_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  programme_id UUID REFERENCES public.programmes(id) ON DELETE CASCADE NOT NULL,
  user_id UUID NOT NULL,
  role programme_member_role NOT NULL DEFAULT 'client',
  permissions TEXT[] DEFAULT ARRAY['view', 'comment'],
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(programme_id, user_id)
);

-- Programme helper functions
CREATE OR REPLACE FUNCTION public.is_programme_member(programme_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.programme_members
    WHERE programme_id = programme_uuid AND user_id = auth.uid()
  )
$$;

CREATE OR REPLACE FUNCTION public.is_programme_ffa_team(programme_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.programme_members
    WHERE programme_id = programme_uuid
    AND user_id = auth.uid()
    AND role = 'ffa_team'
  )
$$;

ALTER TABLE public.programmes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.programme_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view their programmes" ON public.programmes FOR SELECT
  USING (public.is_programme_member(id) OR created_by = auth.uid());
CREATE POLICY "FFA team can create programmes" ON public.programmes FOR INSERT
  WITH CHECK (auth.uid() = created_by);
CREATE POLICY "FFA team can update programmes" ON public.programmes FOR UPDATE
  USING (public.is_programme_ffa_team(id) OR created_by = auth.uid());

CREATE POLICY "Members can view programme members" ON public.programme_members FOR SELECT
  USING (public.is_programme_member(programme_id));
CREATE POLICY "FFA team can manage members" ON public.programme_members FOR INSERT
  WITH CHECK (public.is_programme_ffa_team(programme_id) OR user_id = auth.uid());
CREATE POLICY "FFA team can update members" ON public.programme_members FOR UPDATE
  USING (public.is_programme_ffa_team(programme_id));
CREATE POLICY "FFA team can remove members" ON public.programme_members FOR DELETE
  USING (public.is_programme_ffa_team(programme_id));

CREATE TRIGGER update_programmes_updated_at
  BEFORE UPDATE ON public.programmes
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Concierge assemblies
CREATE TABLE public.concierge_assemblies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  programme_id UUID REFERENCES public.programmes(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  goal_statement TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  current_stage programme_stage NOT NULL DEFAULT 'discover',
  challenge_type TEXT,
  target_metrics JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.concierge_assemblies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view assemblies" ON public.concierge_assemblies FOR SELECT
  USING (public.is_programme_member(programme_id));
CREATE POLICY "FFA team can manage assemblies" ON public.concierge_assemblies FOR INSERT
  WITH CHECK (public.is_programme_ffa_team(programme_id));
CREATE POLICY "FFA team can update assemblies" ON public.concierge_assemblies FOR UPDATE
  USING (public.is_programme_ffa_team(programme_id));

CREATE TRIGGER update_concierge_assemblies_updated_at
  BEFORE UPDATE ON public.concierge_assemblies
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Programme stages
CREATE TABLE public.programme_stages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  concierge_assembly_id UUID REFERENCES public.concierge_assemblies(id) ON DELETE CASCADE NOT NULL,
  stage_type programme_stage NOT NULL,
  description TEXT,
  expected_outcomes TEXT[],
  status TEXT NOT NULL DEFAULT 'pending',
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(concierge_assembly_id, stage_type)
);

ALTER TABLE public.programme_stages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view stages" ON public.programme_stages FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.concierge_assemblies ca WHERE ca.id = concierge_assembly_id
    AND public.is_programme_member(ca.programme_id)));
CREATE POLICY "FFA team can manage stages" ON public.programme_stages FOR ALL
  USING (EXISTS (SELECT 1 FROM public.concierge_assemblies ca WHERE ca.id = concierge_assembly_id
    AND public.is_programme_ffa_team(ca.programme_id)));

CREATE TRIGGER update_programme_stages_updated_at
  BEFORE UPDATE ON public.programme_stages
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Programme actions
CREATE TABLE public.programme_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  programme_id UUID REFERENCES public.programmes(id) ON DELETE CASCADE NOT NULL,
  concierge_assembly_id UUID REFERENCES public.concierge_assemblies(id) ON DELETE SET NULL,
  stage_id UUID REFERENCES public.programme_stages(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  assigned_to UUID,
  assigned_role programme_member_role,
  due_date DATE,
  status TEXT NOT NULL DEFAULT 'pending',
  completed_at TIMESTAMPTZ,
  created_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.programme_actions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view actions" ON public.programme_actions FOR SELECT
  USING (public.is_programme_member(programme_id));
CREATE POLICY "Members can update assigned actions" ON public.programme_actions FOR UPDATE
  USING (assigned_to = auth.uid() OR public.is_programme_ffa_team(programme_id));
CREATE POLICY "FFA team can create actions" ON public.programme_actions FOR INSERT
  WITH CHECK (public.is_programme_ffa_team(programme_id));

CREATE TRIGGER update_programme_actions_updated_at
  BEFORE UPDATE ON public.programme_actions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Programme meetings
CREATE TABLE public.programme_meetings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  programme_id UUID REFERENCES public.programmes(id) ON DELETE CASCADE NOT NULL,
  concierge_assembly_id UUID REFERENCES public.concierge_assemblies(id) ON DELETE SET NULL,
  stage_id UUID REFERENCES public.programme_stages(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  scheduled_at TIMESTAMPTZ,
  duration_minutes INTEGER DEFAULT 60,
  meeting_link TEXT,
  notes TEXT,
  created_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.programme_meetings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view meetings" ON public.programme_meetings FOR SELECT
  USING (public.is_programme_member(programme_id));
CREATE POLICY "FFA team can manage meetings" ON public.programme_meetings FOR ALL
  USING (public.is_programme_ffa_team(programme_id));

CREATE TRIGGER update_programme_meetings_updated_at
  BEFORE UPDATE ON public.programme_meetings
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Programme reports
CREATE TABLE public.programme_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  programme_id UUID REFERENCES public.programmes(id) ON DELETE CASCADE NOT NULL,
  concierge_assembly_id UUID REFERENCES public.concierge_assemblies(id) ON DELETE SET NULL,
  stage_id UUID REFERENCES public.programme_stages(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  context TEXT,
  summary TEXT,
  findings TEXT,
  recommendations TEXT,
  related_assembly_ids TEXT[],
  related_match_ids TEXT[],
  created_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.programme_reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view reports" ON public.programme_reports FOR SELECT
  USING (public.is_programme_member(programme_id));
CREATE POLICY "FFA team can manage reports" ON public.programme_reports FOR ALL
  USING (public.is_programme_ffa_team(programme_id));

CREATE TRIGGER update_programme_reports_updated_at
  BEFORE UPDATE ON public.programme_reports
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Programme feedback
CREATE TABLE public.programme_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  programme_id UUID REFERENCES public.programmes(id) ON DELETE CASCADE NOT NULL,
  user_id UUID NOT NULL,
  target_type TEXT NOT NULL,
  target_id TEXT NOT NULL,
  response feedback_response NOT NULL,
  comment TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.programme_feedback ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Members can view feedback" ON public.programme_feedback FOR SELECT
  USING (public.is_programme_member(programme_id));
CREATE POLICY "Members can create feedback" ON public.programme_feedback FOR INSERT
  WITH CHECK (public.is_programme_member(programme_id) AND user_id = auth.uid());

-- Programme notes
CREATE TABLE public.programme_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  programme_id UUID REFERENCES public.programmes(id) ON DELETE CASCADE NOT NULL,
  user_id UUID NOT NULL,
  content TEXT NOT NULL,
  is_internal BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.programme_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "FFA team can view notes" ON public.programme_notes FOR SELECT
  USING (public.is_programme_ffa_team(programme_id));
CREATE POLICY "FFA team can manage notes" ON public.programme_notes FOR ALL
  USING (public.is_programme_ffa_team(programme_id));

CREATE TRIGGER update_programme_notes_updated_at
  BEFORE UPDATE ON public.programme_notes
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Programme documents (with version control)
CREATE TABLE public.programme_documents (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  programme_id UUID NOT NULL REFERENCES public.programmes(id) ON DELETE CASCADE,
  concierge_assembly_id UUID REFERENCES public.concierge_assemblies(id) ON DELETE SET NULL,
  stage_type TEXT,
  name TEXT NOT NULL,
  description TEXT,
  file_path TEXT NOT NULL,
  file_size BIGINT,
  mime_type TEXT,
  version INTEGER NOT NULL DEFAULT 1,
  parent_document_id UUID REFERENCES public.programme_documents(id) ON DELETE SET NULL,
  is_latest BOOLEAN NOT NULL DEFAULT true,
  uploaded_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.programme_documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Programme members can view documents" ON public.programme_documents FOR SELECT
  USING (public.is_programme_member(programme_id));
CREATE POLICY "FFA team can upload documents" ON public.programme_documents FOR INSERT
  WITH CHECK (public.is_programme_ffa_team(programme_id));
CREATE POLICY "FFA team can update documents" ON public.programme_documents FOR UPDATE
  USING (public.is_programme_ffa_team(programme_id));
CREATE POLICY "FFA team can delete documents" ON public.programme_documents FOR DELETE
  USING (public.is_programme_ffa_team(programme_id));

-- =====================================================
-- Part 11: Connections & Messaging System
-- =====================================================

CREATE TABLE public.connection_tiers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tier subscription_tier UNIQUE NOT NULL,
  max_direct_connections integer NOT NULL DEFAULT 3,
  auto_approve_limit integer NOT NULL DEFAULT 2,
  can_message_without_connection boolean NOT NULL DEFAULT false,
  message_retention_days integer NOT NULL DEFAULT 90,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

INSERT INTO public.connection_tiers (tier, max_direct_connections, auto_approve_limit, can_message_without_connection, message_retention_days) VALUES
  ('free', 3, 2, false, 30),
  ('starter', 10, 5, false, 90),
  ('pro', 50, 25, true, 365),
  ('enterprise', -1, -1, true, -1);

CREATE TABLE public.user_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  tier subscription_tier NOT NULL DEFAULT 'free',
  valid_until timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

CREATE TABLE public.connections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id uuid NOT NULL,
  recipient_id uuid NOT NULL,
  context_type connection_context NOT NULL DEFAULT 'direct',
  context_id text,
  status connection_status NOT NULL DEFAULT 'pending',
  message text,
  approved_by uuid,
  auto_approved boolean NOT NULL DEFAULT false,
  approved_at timestamp with time zone,
  rejected_reason text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  UNIQUE(requester_id, recipient_id, context_type, context_id)
);

CREATE TABLE public.conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  connection_id uuid REFERENCES public.connections(id) ON DELETE CASCADE,
  context_type connection_context NOT NULL DEFAULT 'direct',
  context_id text,
  is_group boolean NOT NULL DEFAULT false,
  title text,
  last_message_at timestamp with time zone NOT NULL DEFAULT now(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

CREATE TABLE public.conversation_participants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL,
  joined_at timestamp with time zone NOT NULL DEFAULT now(),
  left_at timestamp with time zone,
  is_muted boolean NOT NULL DEFAULT false,
  last_read_at timestamp with time zone NOT NULL DEFAULT now(),
  UNIQUE(conversation_id, user_id)
);

CREATE TABLE public.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id uuid NOT NULL,
  content text NOT NULL,
  message_type text NOT NULL DEFAULT 'text',
  metadata jsonb DEFAULT '{}'::jsonb,
  is_deleted boolean NOT NULL DEFAULT false,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

CREATE TABLE public.message_reads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id uuid NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
  user_id uuid NOT NULL,
  read_at timestamp with time zone NOT NULL DEFAULT now(),
  UNIQUE(message_id, user_id)
);

CREATE TABLE public.data_export_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  export_url text,
  requested_at timestamp with time zone NOT NULL DEFAULT now(),
  completed_at timestamp with time zone,
  expires_at timestamp with time zone
);

ALTER TABLE public.connection_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_reads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.data_export_requests ENABLE ROW LEVEL SECURITY;

-- Helper functions for connections
CREATE OR REPLACE FUNCTION public.get_user_connection_count(target_user_id uuid)
RETURNS integer LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT COUNT(*)::integer FROM public.connections
  WHERE (requester_id = target_user_id OR recipient_id = target_user_id) AND status = 'approved';
$$;

CREATE OR REPLACE FUNCTION public.is_conversation_participant(conv_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (SELECT 1 FROM public.conversation_participants
    WHERE conversation_id = conv_id AND user_id = auth.uid() AND left_at IS NULL);
$$;

-- Connection tiers policies
CREATE POLICY "Anyone can view tiers" ON public.connection_tiers FOR SELECT USING (true);
CREATE POLICY "Super admins can manage tiers" ON public.connection_tiers FOR ALL USING (is_super_admin());

-- User subscriptions policies
CREATE POLICY "Users can view own subscription" ON public.user_subscriptions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Super admins can manage subscriptions" ON public.user_subscriptions FOR ALL USING (is_super_admin());

-- Connections policies
CREATE POLICY "Users can view own connections" ON public.connections FOR SELECT
  USING (requester_id = auth.uid() OR recipient_id = auth.uid());
CREATE POLICY "Users can create connection requests" ON public.connections FOR INSERT
  WITH CHECK (requester_id = auth.uid());
CREATE POLICY "Users can update own pending requests" ON public.connections FOR UPDATE
  USING ((requester_id = auth.uid() AND status = 'pending') OR recipient_id = auth.uid());
CREATE POLICY "Super admins can manage all connections" ON public.connections FOR ALL
  USING (is_super_admin());

-- Conversations policies
CREATE POLICY "Participants can view conversations" ON public.conversations FOR SELECT
  USING (is_conversation_participant(id));
CREATE POLICY "Participants can create conversations" ON public.conversations FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM public.connections c WHERE c.id = connection_id AND c.status = 'approved'
    AND (c.requester_id = auth.uid() OR c.recipient_id = auth.uid())));
CREATE POLICY "Super admins can view all conversations" ON public.conversations FOR SELECT
  USING (is_super_admin());

-- Conversation participants policies
CREATE POLICY "View own participation" ON public.conversation_participants FOR SELECT
  USING (user_id = auth.uid() OR is_conversation_participant(conversation_id));
CREATE POLICY "Add self to conversation" ON public.conversation_participants FOR INSERT
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "Update own participation" ON public.conversation_participants FOR UPDATE
  USING (user_id = auth.uid());

-- Messages policies
CREATE POLICY "Participants can view messages" ON public.messages FOR SELECT
  USING (is_conversation_participant(conversation_id) AND is_deleted = false);
CREATE POLICY "Participants can send messages" ON public.messages FOR INSERT
  WITH CHECK (sender_id = auth.uid() AND is_conversation_participant(conversation_id));
CREATE POLICY "Users can soft-delete own messages" ON public.messages FOR UPDATE
  USING (sender_id = auth.uid());
CREATE POLICY "Super admins can view all messages" ON public.messages FOR SELECT
  USING (is_super_admin());

-- Message reads policies
CREATE POLICY "Users can view reads" ON public.message_reads FOR SELECT
  USING (user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.messages m WHERE m.id = message_id AND m.sender_id = auth.uid()));
CREATE POLICY "Users can mark as read" ON public.message_reads FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Data export policies
CREATE POLICY "Users can view own export requests" ON public.data_export_requests FOR SELECT
  USING (user_id = auth.uid());
CREATE POLICY "Users can create export requests" ON public.data_export_requests FOR INSERT
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "Super admins can manage exports" ON public.data_export_requests FOR ALL
  USING (is_super_admin());

-- Indexes for messaging
CREATE INDEX idx_connections_requester ON public.connections(requester_id);
CREATE INDEX idx_connections_recipient ON public.connections(recipient_id);
CREATE INDEX idx_connections_status ON public.connections(status);
CREATE INDEX idx_messages_conversation ON public.messages(conversation_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX idx_conversation_participants_user ON public.conversation_participants(user_id);
CREATE INDEX idx_conversation_participants_conv ON public.conversation_participants(conversation_id);

-- Trigger to update conversation last_message_at
CREATE OR REPLACE FUNCTION public.update_conversation_last_message()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  UPDATE public.conversations SET last_message_at = NEW.created_at, updated_at = now()
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_message_created
  AFTER INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.update_conversation_last_message();

-- Trigger to auto-create user subscription
CREATE OR REPLACE FUNCTION public.create_user_subscription()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.user_subscriptions (user_id, tier) VALUES (NEW.user_id, 'free')
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_profile_created
  AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.create_user_subscription();

-- =====================================================
-- Part 12: External Signals & Signal Topics
-- =====================================================

CREATE TABLE public.signal_topics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  query text NOT NULL,
  category text NOT NULL DEFAULT 'general',
  description text,
  is_active boolean DEFAULT true,
  priority integer DEFAULT 1,
  engagement_count integer DEFAULT 0,
  last_fetched_at timestamp with time zone,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

ALTER TABLE public.signal_topics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active signal topics" ON public.signal_topics FOR SELECT
  USING (is_active = true OR public.is_super_admin());
CREATE POLICY "Super admins can manage signal topics" ON public.signal_topics FOR ALL
  USING (public.is_super_admin());

CREATE TRIGGER update_signal_topics_updated_at
  BEFORE UPDATE ON public.signal_topics
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE public.external_signals (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  source_url TEXT NOT NULL UNIQUE,
  source_name TEXT NOT NULL,
  title TEXT NOT NULL,
  summary TEXT,
  content_type TEXT NOT NULL CHECK (content_type IN ('article', 'video', 'news', 'report', 'podcast')),
  thumbnail_url TEXT,
  video_url TEXT,
  published_at TIMESTAMP WITH TIME ZONE,
  scraped_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  signal_type TEXT CHECK (signal_type IN ('regulatory', 'market', 'technology', 'adoption', 'industry')),
  tags TEXT[] DEFAULT '{}',
  relevance_sectors TEXT[] DEFAULT '{}',
  relevance_challenges TEXT[] DEFAULT '{}',
  is_featured BOOLEAN DEFAULT false,
  is_hidden BOOLEAN DEFAULT false,
  featured_order INTEGER,
  curated_by UUID REFERENCES auth.users(id),
  curated_at TIMESTAMP WITH TIME ZONE,
  topic_id UUID REFERENCES public.signal_topics(id),
  view_count INTEGER DEFAULT 0,
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (now() + interval '30 days'),
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_external_signals_type ON public.external_signals(content_type);
CREATE INDEX idx_external_signals_published ON public.external_signals(published_at DESC);
CREATE INDEX idx_external_signals_signal_type ON public.external_signals(signal_type);
CREATE INDEX idx_external_signals_featured ON public.external_signals(is_featured);
CREATE INDEX idx_external_signals_expires ON public.external_signals(expires_at);

ALTER TABLE public.external_signals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view external signals" ON public.external_signals FOR SELECT USING (true);
CREATE POLICY "Super admins can manage external signals" ON public.external_signals FOR ALL
  USING (public.is_super_admin());

-- Insert default signal topics
INSERT INTO public.signal_topics (name, query, category, description, priority) VALUES
  ('Fashion Sustainability Regulation', 'fashion sustainability regulation 2026', 'Sustainability', 'EU and global sustainability regulations affecting fashion', 5),
  ('Digital Product Passport', 'digital product passport textile DPP', 'Regulation', 'Digital product passport requirements and implementations', 5),
  ('Circular Fashion Tech', 'circular fashion technology innovation', 'Sustainability', 'Circular economy technologies for fashion', 4),
  ('Supply Chain Traceability', 'fashion supply chain traceability blockchain', 'Supply Chain', 'Supply chain visibility and traceability tech', 5),
  ('Materials Science Fashion', 'innovative materials fashion textiles sustainable', 'Materials', 'New materials and textile innovations', 5),
  ('Fashion Retail Innovation', 'fashion retail technology innovation 2025', 'Retail', 'Retail tech and consumer experience innovations', 4),
  ('Fashion Tech Investment', 'fashion tech startup investment funding', 'Industry', 'Investment trends in fashion technology', 4);

-- =====================================================
-- Part 13: Feature Requests & Usage Tracking
-- =====================================================

CREATE TABLE public.feature_requests (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'general',
  status TEXT NOT NULL DEFAULT 'under_review' CHECK (status IN ('under_review', 'planned', 'in_development', 'shipped', 'declined')),
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  upvote_count INTEGER NOT NULL DEFAULT 0,
  downvote_count INTEGER NOT NULL DEFAULT 0,
  admin_notes TEXT,
  target_release TEXT,
  is_featured BOOLEAN DEFAULT false
);

CREATE TABLE public.feature_votes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  feature_id UUID NOT NULL REFERENCES public.feature_requests(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  vote_type TEXT NOT NULL CHECK (vote_type IN ('up', 'down')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(feature_id, user_id)
);

CREATE TABLE public.feature_usage (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID,
  feature_name TEXT NOT NULL,
  action TEXT NOT NULL,
  metadata JSONB DEFAULT '{}',
  session_id TEXT,
  page_path TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.feature_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feature_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feature_usage ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view feature requests" ON public.feature_requests FOR SELECT USING (true);
CREATE POLICY "Authenticated can create feature requests" ON public.feature_requests FOR INSERT
  WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Creators can update own requests" ON public.feature_requests FOR UPDATE
  USING (auth.uid() = created_by);
CREATE POLICY "Admins can manage all requests" ON public.feature_requests FOR ALL
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND is_admin = true));

CREATE POLICY "Anyone can view votes" ON public.feature_votes FOR SELECT USING (true);
CREATE POLICY "Users can vote" ON public.feature_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own vote" ON public.feature_votes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own vote" ON public.feature_votes FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Admins can view usage" ON public.feature_usage FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.profiles WHERE user_id = auth.uid() AND is_admin = true));
CREATE POLICY "Anyone can log usage" ON public.feature_usage FOR INSERT WITH CHECK (true);

-- =====================================================
-- Part 14: Storage Buckets
-- =====================================================

INSERT INTO storage.buckets (id, name, public) VALUES ('program-documents', 'program-documents', false);
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('programme-documents', 'programme-documents', false, 52428800,
  ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'image/jpeg', 'image/png', 'image/gif']);

CREATE POLICY "Program participants can upload documents" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'program-documents' AND auth.uid() IS NOT NULL);
CREATE POLICY "Program participants can view documents" ON storage.objects FOR SELECT
  USING (bucket_id = 'program-documents' AND auth.uid() IS NOT NULL);
CREATE POLICY "Users can delete their own uploads" ON storage.objects FOR DELETE
  USING (bucket_id = 'program-documents' AND auth.uid()::text = (storage.foldername(name))[1]);

-- =====================================================
-- Part 15: Enable Realtime
-- =====================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.follows;
ALTER PUBLICATION supabase_realtime ADD TABLE public.user_actions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.email_preferences;
ALTER PUBLICATION supabase_realtime ADD TABLE public.program_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.programme_feedback;
ALTER PUBLICATION supabase_realtime ADD TABLE public.programme_actions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.connections;
ALTER PUBLICATION supabase_realtime ADD TABLE public.external_signals;