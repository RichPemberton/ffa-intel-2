export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  public: {
    Tables: {
      assembly_members: {
        Row: {
          assembly_id: string
          id: string
          invitation_message: string | null
          invited_by: string | null
          joined_at: string | null
          role: string
          updated_at: string | null
          user_id: string
        }
        Insert: {
          assembly_id: string
          id?: string
          invitation_message?: string | null
          invited_by?: string | null
          joined_at?: string | null
          role?: string
          updated_at?: string | null
          user_id: string
        }
        Update: {
          assembly_id?: string
          id?: string
          invitation_message?: string | null
          invited_by?: string | null
          joined_at?: string | null
          role?: string
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "assembly_members_assembly_id_fkey"
            columns: ["assembly_id"]
            isOneToOne: false
            referencedRelation: "assembly_proposals"
            referencedColumns: ["id"]
          },
        ]
      }
      assembly_proposals: {
        Row: {
          access_model: string | null
          buyer_use_cases: string[]
          components: Json
          created_at: string
          expected_maturity: string
          id: string
          kpis: string[]
          name: string
          primary_challenge: string
          problem_statement: string
          requires_premium: boolean | null
          sectors: string[]
          share_token: string | null
          status: string
          target_participants: number
          timeline: string
          updated_at: string
          user_id: string
          visibility: string
        }
        Insert: {
          access_model?: string | null
          buyer_use_cases?: string[]
          components?: Json
          created_at?: string
          expected_maturity: string
          id?: string
          kpis?: string[]
          name: string
          primary_challenge: string
          problem_statement: string
          requires_premium?: boolean | null
          sectors?: string[]
          share_token?: string | null
          status?: string
          target_participants?: number
          timeline: string
          updated_at?: string
          user_id: string
          visibility?: string
        }
        Update: {
          access_model?: string | null
          buyer_use_cases?: string[]
          components?: Json
          created_at?: string
          expected_maturity?: string
          id?: string
          kpis?: string[]
          name?: string
          primary_challenge?: string
          problem_statement?: string
          requires_premium?: boolean | null
          sectors?: string[]
          share_token?: string | null
          status?: string
          target_participants?: number
          timeline?: string
          updated_at?: string
          user_id?: string
          visibility?: string
        }
        Relationships: []
      }
      challenge_categories: {
        Row: {
          created_at: string
          description: string | null
          display_order: number | null
          id: string
          name: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          display_order?: number | null
          id?: string
          name: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          display_order?: number | null
          id?: string
          name?: string
          updated_at?: string
        }
        Relationships: []
      }
      concierge_assemblies: {
        Row: {
          challenge_type: string | null
          created_at: string
          current_stage: Database["public"]["Enums"]["programme_stage"]
          goal_statement: string
          id: string
          programme_id: string
          status: string
          target_metrics: Json | null
          title: string
          updated_at: string
        }
        Insert: {
          challenge_type?: string | null
          created_at?: string
          current_stage?: Database["public"]["Enums"]["programme_stage"]
          goal_statement: string
          id?: string
          programme_id: string
          status?: string
          target_metrics?: Json | null
          title: string
          updated_at?: string
        }
        Update: {
          challenge_type?: string | null
          created_at?: string
          current_stage?: Database["public"]["Enums"]["programme_stage"]
          goal_statement?: string
          id?: string
          programme_id?: string
          status?: string
          target_metrics?: Json | null
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "concierge_assemblies_programme_id_fkey"
            columns: ["programme_id"]
            isOneToOne: false
            referencedRelation: "programmes"
            referencedColumns: ["id"]
          },
        ]
      }
      connection_tiers: {
        Row: {
          auto_approve_limit: number
          can_message_without_connection: boolean
          created_at: string
          id: string
          max_direct_connections: number
          message_retention_days: number
          tier: Database["public"]["Enums"]["subscription_tier"]
          updated_at: string
        }
        Insert: {
          auto_approve_limit?: number
          can_message_without_connection?: boolean
          created_at?: string
          id?: string
          max_direct_connections?: number
          message_retention_days?: number
          tier: Database["public"]["Enums"]["subscription_tier"]
          updated_at?: string
        }
        Update: {
          auto_approve_limit?: number
          can_message_without_connection?: boolean
          created_at?: string
          id?: string
          max_direct_connections?: number
          message_retention_days?: number
          tier?: Database["public"]["Enums"]["subscription_tier"]
          updated_at?: string
        }
        Relationships: []
      }
      connections: {
        Row: {
          approved_at: string | null
          approved_by: string | null
          auto_approved: boolean
          context_id: string | null
          context_type: Database["public"]["Enums"]["connection_context"]
          created_at: string
          id: string
          message: string | null
          recipient_id: string
          rejected_reason: string | null
          requester_id: string
          status: Database["public"]["Enums"]["connection_status"]
          updated_at: string
        }
        Insert: {
          approved_at?: string | null
          approved_by?: string | null
          auto_approved?: boolean
          context_id?: string | null
          context_type?: Database["public"]["Enums"]["connection_context"]
          created_at?: string
          id?: string
          message?: string | null
          recipient_id: string
          rejected_reason?: string | null
          requester_id: string
          status?: Database["public"]["Enums"]["connection_status"]
          updated_at?: string
        }
        Update: {
          approved_at?: string | null
          approved_by?: string | null
          auto_approved?: boolean
          context_id?: string | null
          context_type?: Database["public"]["Enums"]["connection_context"]
          created_at?: string
          id?: string
          message?: string | null
          recipient_id?: string
          rejected_reason?: string | null
          requester_id?: string
          status?: Database["public"]["Enums"]["connection_status"]
          updated_at?: string
        }
        Relationships: []
      }
      conversation_participants: {
        Row: {
          conversation_id: string
          id: string
          is_muted: boolean
          joined_at: string
          last_read_at: string
          left_at: string | null
          user_id: string
        }
        Insert: {
          conversation_id: string
          id?: string
          is_muted?: boolean
          joined_at?: string
          last_read_at?: string
          left_at?: string | null
          user_id: string
        }
        Update: {
          conversation_id?: string
          id?: string
          is_muted?: boolean
          joined_at?: string
          last_read_at?: string
          left_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "conversation_participants_conversation_id_fkey"
            columns: ["conversation_id"]
            isOneToOne: false
            referencedRelation: "conversations"
            referencedColumns: ["id"]
          },
        ]
      }
      conversations: {
        Row: {
          connection_id: string | null
          context_id: string | null
          context_type: Database["public"]["Enums"]["connection_context"]
          created_at: string
          id: string
          is_group: boolean
          last_message_at: string
          title: string | null
          updated_at: string
        }
        Insert: {
          connection_id?: string | null
          context_id?: string | null
          context_type?: Database["public"]["Enums"]["connection_context"]
          created_at?: string
          id?: string
          is_group?: boolean
          last_message_at?: string
          title?: string | null
          updated_at?: string
        }
        Update: {
          connection_id?: string | null
          context_id?: string | null
          context_type?: Database["public"]["Enums"]["connection_context"]
          created_at?: string
          id?: string
          is_group?: boolean
          last_message_at?: string
          title?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "conversations_connection_id_fkey"
            columns: ["connection_id"]
            isOneToOne: false
            referencedRelation: "connections"
            referencedColumns: ["id"]
          },
        ]
      }
      custom_challenges: {
        Row: {
          assembly_id: string | null
          category: string | null
          created_at: string
          created_by: string
          description: string | null
          id: string
          is_approved: boolean | null
          name: string
          scope: string
          updated_at: string
          usage_count: number | null
        }
        Insert: {
          assembly_id?: string | null
          category?: string | null
          created_at?: string
          created_by: string
          description?: string | null
          id?: string
          is_approved?: boolean | null
          name: string
          scope?: string
          updated_at?: string
          usage_count?: number | null
        }
        Update: {
          assembly_id?: string | null
          category?: string | null
          created_at?: string
          created_by?: string
          description?: string | null
          id?: string
          is_approved?: boolean | null
          name?: string
          scope?: string
          updated_at?: string
          usage_count?: number | null
        }
        Relationships: []
      }
      data_export_requests: {
        Row: {
          completed_at: string | null
          expires_at: string | null
          export_url: string | null
          id: string
          requested_at: string
          status: string
          user_id: string
        }
        Insert: {
          completed_at?: string | null
          expires_at?: string | null
          export_url?: string | null
          id?: string
          requested_at?: string
          status?: string
          user_id: string
        }
        Update: {
          completed_at?: string | null
          expires_at?: string | null
          export_url?: string | null
          id?: string
          requested_at?: string
          status?: string
          user_id?: string
        }
        Relationships: []
      }
      email_preferences: {
        Row: {
          assembly_updates: boolean | null
          created_at: string
          email: string
          id: string
          notifications_enabled: boolean | null
          signal_updates: boolean | null
          updated_at: string
          user_id: string
          weekly_digest: boolean | null
        }
        Insert: {
          assembly_updates?: boolean | null
          created_at?: string
          email: string
          id?: string
          notifications_enabled?: boolean | null
          signal_updates?: boolean | null
          updated_at?: string
          user_id: string
          weekly_digest?: boolean | null
        }
        Update: {
          assembly_updates?: boolean | null
          created_at?: string
          email?: string
          id?: string
          notifications_enabled?: boolean | null
          signal_updates?: boolean | null
          updated_at?: string
          user_id?: string
          weekly_digest?: boolean | null
        }
        Relationships: []
      }
      external_signals: {
        Row: {
          content_type: string
          created_at: string
          curated_at: string | null
          curated_by: string | null
          expires_at: string | null
          featured_order: number | null
          id: string
          is_featured: boolean | null
          is_hidden: boolean | null
          metadata: Json | null
          published_at: string | null
          relevance_challenges: string[] | null
          relevance_sectors: string[] | null
          scraped_at: string
          signal_type: string | null
          source_name: string
          source_url: string
          summary: string | null
          tags: string[] | null
          thumbnail_url: string | null
          title: string
          topic_id: string | null
          video_url: string | null
          view_count: number | null
        }
        Insert: {
          content_type: string
          created_at?: string
          curated_at?: string | null
          curated_by?: string | null
          expires_at?: string | null
          featured_order?: number | null
          id?: string
          is_featured?: boolean | null
          is_hidden?: boolean | null
          metadata?: Json | null
          published_at?: string | null
          relevance_challenges?: string[] | null
          relevance_sectors?: string[] | null
          scraped_at?: string
          signal_type?: string | null
          source_name: string
          source_url: string
          summary?: string | null
          tags?: string[] | null
          thumbnail_url?: string | null
          title: string
          topic_id?: string | null
          video_url?: string | null
          view_count?: number | null
        }
        Update: {
          content_type?: string
          created_at?: string
          curated_at?: string | null
          curated_by?: string | null
          expires_at?: string | null
          featured_order?: number | null
          id?: string
          is_featured?: boolean | null
          is_hidden?: boolean | null
          metadata?: Json | null
          published_at?: string | null
          relevance_challenges?: string[] | null
          relevance_sectors?: string[] | null
          scraped_at?: string
          signal_type?: string | null
          source_name?: string
          source_url?: string
          summary?: string | null
          tags?: string[] | null
          thumbnail_url?: string | null
          title?: string
          topic_id?: string | null
          video_url?: string | null
          view_count?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "external_signals_topic_id_fkey"
            columns: ["topic_id"]
            isOneToOne: false
            referencedRelation: "signal_topics"
            referencedColumns: ["id"]
          },
        ]
      }
      feature_requests: {
        Row: {
          admin_notes: string | null
          category: string
          created_at: string
          created_by: string
          description: string
          downvote_count: number
          id: string
          is_featured: boolean | null
          status: string
          target_release: string | null
          title: string
          updated_at: string
          upvote_count: number
        }
        Insert: {
          admin_notes?: string | null
          category?: string
          created_at?: string
          created_by: string
          description: string
          downvote_count?: number
          id?: string
          is_featured?: boolean | null
          status?: string
          target_release?: string | null
          title: string
          updated_at?: string
          upvote_count?: number
        }
        Update: {
          admin_notes?: string | null
          category?: string
          created_at?: string
          created_by?: string
          description?: string
          downvote_count?: number
          id?: string
          is_featured?: boolean | null
          status?: string
          target_release?: string | null
          title?: string
          updated_at?: string
          upvote_count?: number
        }
        Relationships: []
      }
      feature_usage: {
        Row: {
          action: string
          created_at: string
          feature_name: string
          id: string
          metadata: Json | null
          page_path: string | null
          session_id: string | null
          user_id: string | null
        }
        Insert: {
          action: string
          created_at?: string
          feature_name: string
          id?: string
          metadata?: Json | null
          page_path?: string | null
          session_id?: string | null
          user_id?: string | null
        }
        Update: {
          action?: string
          created_at?: string
          feature_name?: string
          id?: string
          metadata?: Json | null
          page_path?: string | null
          session_id?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      feature_votes: {
        Row: {
          created_at: string
          feature_id: string
          id: string
          user_id: string
          vote_type: string
        }
        Insert: {
          created_at?: string
          feature_id: string
          id?: string
          user_id: string
          vote_type: string
        }
        Update: {
          created_at?: string
          feature_id?: string
          id?: string
          user_id?: string
          vote_type?: string
        }
        Relationships: [
          {
            foreignKeyName: "feature_votes_feature_id_fkey"
            columns: ["feature_id"]
            isOneToOne: false
            referencedRelation: "feature_requests"
            referencedColumns: ["id"]
          },
        ]
      }
      follows: {
        Row: {
          created_at: string
          id: string
          target_id: string
          target_type: Database["public"]["Enums"]["follow_target_type"]
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          target_id: string
          target_type: Database["public"]["Enums"]["follow_target_type"]
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          target_id?: string
          target_type?: Database["public"]["Enums"]["follow_target_type"]
          user_id?: string
        }
        Relationships: []
      }
      innovation_programs: {
        Row: {
          assembly_id: string | null
          buyer_contact: string | null
          buyer_id: string | null
          buyer_name: string
          created_at: string
          created_by: string | null
          description: string
          id: string
          innovator_contact: string | null
          innovator_id: string | null
          innovator_name: string
          kpis: Json | null
          milestones: Json | null
          name: string
          next_action: Json | null
          objectives: string[] | null
          primary_challenge: string | null
          sectors: string[] | null
          start_date: string | null
          status: string
          target_end_date: string | null
          updated_at: string
        }
        Insert: {
          assembly_id?: string | null
          buyer_contact?: string | null
          buyer_id?: string | null
          buyer_name: string
          created_at?: string
          created_by?: string | null
          description: string
          id?: string
          innovator_contact?: string | null
          innovator_id?: string | null
          innovator_name: string
          kpis?: Json | null
          milestones?: Json | null
          name: string
          next_action?: Json | null
          objectives?: string[] | null
          primary_challenge?: string | null
          sectors?: string[] | null
          start_date?: string | null
          status?: string
          target_end_date?: string | null
          updated_at?: string
        }
        Update: {
          assembly_id?: string | null
          buyer_contact?: string | null
          buyer_id?: string | null
          buyer_name?: string
          created_at?: string
          created_by?: string | null
          description?: string
          id?: string
          innovator_contact?: string | null
          innovator_id?: string | null
          innovator_name?: string
          kpis?: Json | null
          milestones?: Json | null
          name?: string
          next_action?: Json | null
          objectives?: string[] | null
          primary_challenge?: string | null
          sectors?: string[] | null
          start_date?: string | null
          status?: string
          target_end_date?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      message_reads: {
        Row: {
          id: string
          message_id: string
          read_at: string
          user_id: string
        }
        Insert: {
          id?: string
          message_id: string
          read_at?: string
          user_id: string
        }
        Update: {
          id?: string
          message_id?: string
          read_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "message_reads_message_id_fkey"
            columns: ["message_id"]
            isOneToOne: false
            referencedRelation: "messages"
            referencedColumns: ["id"]
          },
        ]
      }
      messages: {
        Row: {
          content: string
          conversation_id: string
          created_at: string
          deleted_at: string | null
          deleted_by: string | null
          id: string
          is_deleted: boolean
          message_type: string
          metadata: Json | null
          sender_id: string
          updated_at: string
        }
        Insert: {
          content: string
          conversation_id: string
          created_at?: string
          deleted_at?: string | null
          deleted_by?: string | null
          id?: string
          is_deleted?: boolean
          message_type?: string
          metadata?: Json | null
          sender_id: string
          updated_at?: string
        }
        Update: {
          content?: string
          conversation_id?: string
          created_at?: string
          deleted_at?: string | null
          deleted_by?: string | null
          id?: string
          is_deleted?: boolean
          message_type?: string
          metadata?: Json | null
          sender_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "messages_conversation_id_fkey"
            columns: ["conversation_id"]
            isOneToOne: false
            referencedRelation: "conversations"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          ai_suggested_challenges: string[] | null
          ai_suggested_sectors: string[] | null
          challenges: string[] | null
          contribution_score: number | null
          created_at: string
          display_name: string | null
          engagement_score: number | null
          id: string
          is_admin: boolean
          maturity_level: Database["public"]["Enums"]["maturity_level"] | null
          onboarding_completed: boolean | null
          organisation_name: string | null
          role: Database["public"]["Enums"]["user_role"]
          sectors: Database["public"]["Enums"]["sector_type"][] | null
          updated_at: string
          user_id: string
          website_scraped_at: string | null
          website_url: string | null
        }
        Insert: {
          ai_suggested_challenges?: string[] | null
          ai_suggested_sectors?: string[] | null
          challenges?: string[] | null
          contribution_score?: number | null
          created_at?: string
          display_name?: string | null
          engagement_score?: number | null
          id?: string
          is_admin?: boolean
          maturity_level?: Database["public"]["Enums"]["maturity_level"] | null
          onboarding_completed?: boolean | null
          organisation_name?: string | null
          role?: Database["public"]["Enums"]["user_role"]
          sectors?: Database["public"]["Enums"]["sector_type"][] | null
          updated_at?: string
          user_id: string
          website_scraped_at?: string | null
          website_url?: string | null
        }
        Update: {
          ai_suggested_challenges?: string[] | null
          ai_suggested_sectors?: string[] | null
          challenges?: string[] | null
          contribution_score?: number | null
          created_at?: string
          display_name?: string | null
          engagement_score?: number | null
          id?: string
          is_admin?: boolean
          maturity_level?: Database["public"]["Enums"]["maturity_level"] | null
          onboarding_completed?: boolean | null
          organisation_name?: string | null
          role?: Database["public"]["Enums"]["user_role"]
          sectors?: Database["public"]["Enums"]["sector_type"][] | null
          updated_at?: string
          user_id?: string
          website_scraped_at?: string | null
          website_url?: string | null
        }
        Relationships: []
      }
      program_documents: {
        Row: {
          category: string | null
          created_at: string
          description: string | null
          file_name: string
          file_size: number | null
          file_type: string | null
          file_url: string
          id: string
          program_id: string
          uploaded_by: string
          uploader_name: string
        }
        Insert: {
          category?: string | null
          created_at?: string
          description?: string | null
          file_name: string
          file_size?: number | null
          file_type?: string | null
          file_url: string
          id?: string
          program_id: string
          uploaded_by: string
          uploader_name: string
        }
        Update: {
          category?: string | null
          created_at?: string
          description?: string | null
          file_name?: string
          file_size?: number | null
          file_type?: string | null
          file_url?: string
          id?: string
          program_id?: string
          uploaded_by?: string
          uploader_name?: string
        }
        Relationships: [
          {
            foreignKeyName: "program_documents_program_id_fkey"
            columns: ["program_id"]
            isOneToOne: false
            referencedRelation: "innovation_programs"
            referencedColumns: ["id"]
          },
        ]
      }
      program_messages: {
        Row: {
          content: string
          created_at: string
          id: string
          message_type: string | null
          metadata: Json | null
          program_id: string
          sender_id: string
          sender_name: string
          sender_role: string
        }
        Insert: {
          content: string
          created_at?: string
          id?: string
          message_type?: string | null
          metadata?: Json | null
          program_id: string
          sender_id: string
          sender_name: string
          sender_role: string
        }
        Update: {
          content?: string
          created_at?: string
          id?: string
          message_type?: string | null
          metadata?: Json | null
          program_id?: string
          sender_id?: string
          sender_name?: string
          sender_role?: string
        }
        Relationships: [
          {
            foreignKeyName: "program_messages_program_id_fkey"
            columns: ["program_id"]
            isOneToOne: false
            referencedRelation: "innovation_programs"
            referencedColumns: ["id"]
          },
        ]
      }
      programme_actions: {
        Row: {
          assigned_role:
            | Database["public"]["Enums"]["programme_member_role"]
            | null
          assigned_to: string | null
          completed_at: string | null
          concierge_assembly_id: string | null
          created_at: string
          created_by: string | null
          description: string | null
          due_date: string | null
          id: string
          programme_id: string
          stage_id: string | null
          status: string
          title: string
          updated_at: string
        }
        Insert: {
          assigned_role?:
            | Database["public"]["Enums"]["programme_member_role"]
            | null
          assigned_to?: string | null
          completed_at?: string | null
          concierge_assembly_id?: string | null
          created_at?: string
          created_by?: string | null
          description?: string | null
          due_date?: string | null
          id?: string
          programme_id: string
          stage_id?: string | null
          status?: string
          title: string
          updated_at?: string
        }
        Update: {
          assigned_role?:
            | Database["public"]["Enums"]["programme_member_role"]
            | null
          assigned_to?: string | null
          completed_at?: string | null
          concierge_assembly_id?: string | null
          created_at?: string
          created_by?: string | null
          description?: string | null
          due_date?: string | null
          id?: string
          programme_id?: string
          stage_id?: string | null
          status?: string
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "programme_actions_concierge_assembly_id_fkey"
            columns: ["concierge_assembly_id"]
            isOneToOne: false
            referencedRelation: "concierge_assemblies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "programme_actions_programme_id_fkey"
            columns: ["programme_id"]
            isOneToOne: false
            referencedRelation: "programmes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "programme_actions_stage_id_fkey"
            columns: ["stage_id"]
            isOneToOne: false
            referencedRelation: "programme_stages"
            referencedColumns: ["id"]
          },
        ]
      }
      programme_documents: {
        Row: {
          concierge_assembly_id: string | null
          created_at: string
          description: string | null
          file_path: string
          file_size: number | null
          id: string
          is_latest: boolean
          mime_type: string | null
          name: string
          parent_document_id: string | null
          programme_id: string
          stage_type: string | null
          updated_at: string
          uploaded_by: string
          version: number
        }
        Insert: {
          concierge_assembly_id?: string | null
          created_at?: string
          description?: string | null
          file_path: string
          file_size?: number | null
          id?: string
          is_latest?: boolean
          mime_type?: string | null
          name: string
          parent_document_id?: string | null
          programme_id: string
          stage_type?: string | null
          updated_at?: string
          uploaded_by: string
          version?: number
        }
        Update: {
          concierge_assembly_id?: string | null
          created_at?: string
          description?: string | null
          file_path?: string
          file_size?: number | null
          id?: string
          is_latest?: boolean
          mime_type?: string | null
          name?: string
          parent_document_id?: string | null
          programme_id?: string
          stage_type?: string | null
          updated_at?: string
          uploaded_by?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "programme_documents_concierge_assembly_id_fkey"
            columns: ["concierge_assembly_id"]
            isOneToOne: false
            referencedRelation: "concierge_assemblies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "programme_documents_parent_document_id_fkey"
            columns: ["parent_document_id"]
            isOneToOne: false
            referencedRelation: "programme_documents"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "programme_documents_programme_id_fkey"
            columns: ["programme_id"]
            isOneToOne: false
            referencedRelation: "programmes"
            referencedColumns: ["id"]
          },
        ]
      }
      programme_feedback: {
        Row: {
          comment: string | null
          created_at: string
          id: string
          metadata: Json | null
          programme_id: string
          response: Database["public"]["Enums"]["feedback_response"]
          target_id: string
          target_type: string
          user_id: string
        }
        Insert: {
          comment?: string | null
          created_at?: string
          id?: string
          metadata?: Json | null
          programme_id: string
          response: Database["public"]["Enums"]["feedback_response"]
          target_id: string
          target_type: string
          user_id: string
        }
        Update: {
          comment?: string | null
          created_at?: string
          id?: string
          metadata?: Json | null
          programme_id?: string
          response?: Database["public"]["Enums"]["feedback_response"]
          target_id?: string
          target_type?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "programme_feedback_programme_id_fkey"
            columns: ["programme_id"]
            isOneToOne: false
            referencedRelation: "programmes"
            referencedColumns: ["id"]
          },
        ]
      }
      programme_meetings: {
        Row: {
          concierge_assembly_id: string | null
          created_at: string
          created_by: string | null
          duration_minutes: number | null
          id: string
          meeting_link: string | null
          notes: string | null
          programme_id: string
          scheduled_at: string | null
          stage_id: string | null
          title: string
          updated_at: string
        }
        Insert: {
          concierge_assembly_id?: string | null
          created_at?: string
          created_by?: string | null
          duration_minutes?: number | null
          id?: string
          meeting_link?: string | null
          notes?: string | null
          programme_id: string
          scheduled_at?: string | null
          stage_id?: string | null
          title: string
          updated_at?: string
        }
        Update: {
          concierge_assembly_id?: string | null
          created_at?: string
          created_by?: string | null
          duration_minutes?: number | null
          id?: string
          meeting_link?: string | null
          notes?: string | null
          programme_id?: string
          scheduled_at?: string | null
          stage_id?: string | null
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "programme_meetings_concierge_assembly_id_fkey"
            columns: ["concierge_assembly_id"]
            isOneToOne: false
            referencedRelation: "concierge_assemblies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "programme_meetings_programme_id_fkey"
            columns: ["programme_id"]
            isOneToOne: false
            referencedRelation: "programmes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "programme_meetings_stage_id_fkey"
            columns: ["stage_id"]
            isOneToOne: false
            referencedRelation: "programme_stages"
            referencedColumns: ["id"]
          },
        ]
      }
      programme_members: {
        Row: {
          id: string
          joined_at: string
          permissions: string[] | null
          programme_id: string
          role: Database["public"]["Enums"]["programme_member_role"]
          user_id: string
        }
        Insert: {
          id?: string
          joined_at?: string
          permissions?: string[] | null
          programme_id: string
          role?: Database["public"]["Enums"]["programme_member_role"]
          user_id: string
        }
        Update: {
          id?: string
          joined_at?: string
          permissions?: string[] | null
          programme_id?: string
          role?: Database["public"]["Enums"]["programme_member_role"]
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "programme_members_programme_id_fkey"
            columns: ["programme_id"]
            isOneToOne: false
            referencedRelation: "programmes"
            referencedColumns: ["id"]
          },
        ]
      }
      programme_notes: {
        Row: {
          content: string
          created_at: string
          id: string
          is_internal: boolean
          programme_id: string
          updated_at: string
          user_id: string
        }
        Insert: {
          content: string
          created_at?: string
          id?: string
          is_internal?: boolean
          programme_id: string
          updated_at?: string
          user_id: string
        }
        Update: {
          content?: string
          created_at?: string
          id?: string
          is_internal?: boolean
          programme_id?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "programme_notes_programme_id_fkey"
            columns: ["programme_id"]
            isOneToOne: false
            referencedRelation: "programmes"
            referencedColumns: ["id"]
          },
        ]
      }
      programme_reports: {
        Row: {
          concierge_assembly_id: string | null
          context: string | null
          created_at: string
          created_by: string | null
          findings: string | null
          id: string
          programme_id: string
          recommendations: string | null
          related_assembly_ids: string[] | null
          related_match_ids: string[] | null
          stage_id: string | null
          summary: string | null
          title: string
          updated_at: string
        }
        Insert: {
          concierge_assembly_id?: string | null
          context?: string | null
          created_at?: string
          created_by?: string | null
          findings?: string | null
          id?: string
          programme_id: string
          recommendations?: string | null
          related_assembly_ids?: string[] | null
          related_match_ids?: string[] | null
          stage_id?: string | null
          summary?: string | null
          title: string
          updated_at?: string
        }
        Update: {
          concierge_assembly_id?: string | null
          context?: string | null
          created_at?: string
          created_by?: string | null
          findings?: string | null
          id?: string
          programme_id?: string
          recommendations?: string | null
          related_assembly_ids?: string[] | null
          related_match_ids?: string[] | null
          stage_id?: string | null
          summary?: string | null
          title?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "programme_reports_concierge_assembly_id_fkey"
            columns: ["concierge_assembly_id"]
            isOneToOne: false
            referencedRelation: "concierge_assemblies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "programme_reports_programme_id_fkey"
            columns: ["programme_id"]
            isOneToOne: false
            referencedRelation: "programmes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "programme_reports_stage_id_fkey"
            columns: ["stage_id"]
            isOneToOne: false
            referencedRelation: "programme_stages"
            referencedColumns: ["id"]
          },
        ]
      }
      programme_stages: {
        Row: {
          completed_at: string | null
          concierge_assembly_id: string
          created_at: string
          description: string | null
          expected_outcomes: string[] | null
          id: string
          stage_type: Database["public"]["Enums"]["programme_stage"]
          started_at: string | null
          status: string
          updated_at: string
        }
        Insert: {
          completed_at?: string | null
          concierge_assembly_id: string
          created_at?: string
          description?: string | null
          expected_outcomes?: string[] | null
          id?: string
          stage_type: Database["public"]["Enums"]["programme_stage"]
          started_at?: string | null
          status?: string
          updated_at?: string
        }
        Update: {
          completed_at?: string | null
          concierge_assembly_id?: string
          created_at?: string
          description?: string | null
          expected_outcomes?: string[] | null
          id?: string
          stage_type?: Database["public"]["Enums"]["programme_stage"]
          started_at?: string | null
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "programme_stages_concierge_assembly_id_fkey"
            columns: ["concierge_assembly_id"]
            isOneToOne: false
            referencedRelation: "concierge_assemblies"
            referencedColumns: ["id"]
          },
        ]
      }
      programmes: {
        Row: {
          client_org_id: string | null
          client_org_name: string
          created_at: string
          created_by: string | null
          description: string | null
          end_date: string | null
          ffa_owner_id: string | null
          framework: string
          id: string
          join_code: string | null
          name: string
          seats_included: number
          seats_used: number
          start_date: string | null
          status: Database["public"]["Enums"]["programme_status"]
          type: Database["public"]["Enums"]["programme_type"]
          updated_at: string
        }
        Insert: {
          client_org_id?: string | null
          client_org_name: string
          created_at?: string
          created_by?: string | null
          description?: string | null
          end_date?: string | null
          ffa_owner_id?: string | null
          framework?: string
          id?: string
          join_code?: string | null
          name: string
          seats_included?: number
          seats_used?: number
          start_date?: string | null
          status?: Database["public"]["Enums"]["programme_status"]
          type?: Database["public"]["Enums"]["programme_type"]
          updated_at?: string
        }
        Update: {
          client_org_id?: string | null
          client_org_name?: string
          created_at?: string
          created_by?: string | null
          description?: string | null
          end_date?: string | null
          ffa_owner_id?: string | null
          framework?: string
          id?: string
          join_code?: string | null
          name?: string
          seats_included?: number
          seats_used?: number
          start_date?: string | null
          status?: Database["public"]["Enums"]["programme_status"]
          type?: Database["public"]["Enums"]["programme_type"]
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "programmes_client_org_id_fkey"
            columns: ["client_org_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      signal_topics: {
        Row: {
          category: string
          created_at: string | null
          created_by: string | null
          description: string | null
          engagement_count: number | null
          id: string
          is_active: boolean | null
          last_fetched_at: string | null
          name: string
          priority: number | null
          query: string
          updated_at: string | null
        }
        Insert: {
          category?: string
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          engagement_count?: number | null
          id?: string
          is_active?: boolean | null
          last_fetched_at?: string | null
          name: string
          priority?: number | null
          query: string
          updated_at?: string | null
        }
        Update: {
          category?: string
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          engagement_count?: number | null
          id?: string
          is_active?: boolean | null
          last_fetched_at?: string | null
          name?: string
          priority?: number | null
          query?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      standard_challenges: {
        Row: {
          category_id: string | null
          created_at: string
          description: string | null
          display_order: number | null
          id: string
          is_active: boolean | null
          name: string
          slug: string
          updated_at: string
        }
        Insert: {
          category_id?: string | null
          created_at?: string
          description?: string | null
          display_order?: number | null
          id?: string
          is_active?: boolean | null
          name: string
          slug: string
          updated_at?: string
        }
        Update: {
          category_id?: string | null
          created_at?: string
          description?: string | null
          display_order?: number | null
          id?: string
          is_active?: boolean | null
          name?: string
          slug?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "standard_challenges_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "challenge_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      user_actions: {
        Row: {
          action_type: Database["public"]["Enums"]["action_type"]
          created_at: string
          id: string
          metadata: Json | null
          target_id: string
          target_name: string | null
          target_type: string
          user_id: string
        }
        Insert: {
          action_type: Database["public"]["Enums"]["action_type"]
          created_at?: string
          id?: string
          metadata?: Json | null
          target_id: string
          target_name?: string | null
          target_type: string
          user_id: string
        }
        Update: {
          action_type?: Database["public"]["Enums"]["action_type"]
          created_at?: string
          id?: string
          metadata?: Json | null
          target_id?: string
          target_name?: string | null
          target_type?: string
          user_id?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          granted_at: string | null
          granted_by: string | null
          id: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Insert: {
          granted_at?: string | null
          granted_by?: string | null
          id?: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Update: {
          granted_at?: string | null
          granted_by?: string | null
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id?: string
        }
        Relationships: []
      }
      user_subscriptions: {
        Row: {
          created_at: string
          id: string
          tier: Database["public"]["Enums"]["subscription_tier"]
          updated_at: string
          user_id: string
          valid_until: string | null
        }
        Insert: {
          created_at?: string
          id?: string
          tier?: Database["public"]["Enums"]["subscription_tier"]
          updated_at?: string
          user_id: string
          valid_until?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          tier?: Database["public"]["Enums"]["subscription_tier"]
          updated_at?: string
          user_id?: string
          valid_until?: string | null
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      get_user_connection_count: {
        Args: { target_user_id: string }
        Returns: number
      }
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
      is_conversation_participant: {
        Args: { conv_id: string }
        Returns: boolean
      }
      is_programme_ffa_team: {
        Args: { programme_uuid: string }
        Returns: boolean
      }
      is_programme_member: {
        Args: { programme_uuid: string }
        Returns: boolean
      }
      is_super_admin: { Args: never; Returns: boolean }
    }
    Enums: {
      action_type:
        | "view"
        | "follow"
        | "join"
        | "pilot_request"
        | "connection_request"
        | "brief_request"
      app_role: "admin" | "super_admin"
      connection_context:
        | "organisation"
        | "assembly"
        | "programme"
        | "concierge"
        | "direct"
      connection_status: "pending" | "approved" | "rejected" | "blocked"
      feedback_response:
        | "save"
        | "interested"
        | "maybe"
        | "not_now"
        | "not_relevant"
      follow_target_type: "assembly" | "signal" | "innovator"
      maturity_level: "early" | "mid" | "advanced"
      programme_member_role: "client" | "ffa_team" | "observer"
      programme_stage:
        | "discover"
        | "source"
        | "assemble"
        | "co-design"
        | "orchestrate"
        | "activate"
      programme_status: "draft" | "active" | "paused" | "completed" | "archived"
      programme_type: "concierge" | "accelerator" | "thematic" | "cohort"
      sector_type:
        | "apparel"
        | "luxury"
        | "sportswear"
        | "footwear"
        | "accessories"
      subscription_tier: "free" | "starter" | "pro" | "enterprise"
      user_role: "buyer" | "innovator" | "partner" | "investor" | "ecosystem"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      action_type: [
        "view",
        "follow",
        "join",
        "pilot_request",
        "connection_request",
        "brief_request",
      ],
      app_role: ["admin", "super_admin"],
      connection_context: [
        "organisation",
        "assembly",
        "programme",
        "concierge",
        "direct",
      ],
      connection_status: ["pending", "approved", "rejected", "blocked"],
      feedback_response: [
        "save",
        "interested",
        "maybe",
        "not_now",
        "not_relevant",
      ],
      follow_target_type: ["assembly", "signal", "innovator"],
      maturity_level: ["early", "mid", "advanced"],
      programme_member_role: ["client", "ffa_team", "observer"],
      programme_stage: [
        "discover",
        "source",
        "assemble",
        "co-design",
        "orchestrate",
        "activate",
      ],
      programme_status: ["draft", "active", "paused", "completed", "archived"],
      programme_type: ["concierge", "accelerator", "thematic", "cohort"],
      sector_type: [
        "apparel",
        "luxury",
        "sportswear",
        "footwear",
        "accessories",
      ],
      subscription_tier: ["free", "starter", "pro", "enterprise"],
      user_role: ["buyer", "innovator", "partner", "investor", "ecosystem"],
    },
  },
} as const
