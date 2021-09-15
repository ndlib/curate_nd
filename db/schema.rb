# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20210914204130) do

  create_table "activity_engine_activities", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.string   "subject_type",  limit: 255,   null: false
    t.string   "subject_id",    limit: 255,   null: false
    t.string   "activity_type", limit: 255,   null: false
    t.text     "message",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activity_engine_activities", ["user_id"], name: "index_activity_engine_activities_on_user_id", using: :btree

  create_table "admin_announcement_dismissals", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.integer  "admin_announcement_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_announcement_dismissals", ["admin_announcement_id"], name: "index_admin_announcement_dismissals_on_admin_announcement_id", using: :btree
  add_index "admin_announcement_dismissals", ["user_id", "admin_announcement_id"], name: "[:admin_announcement_dismissals_join_index]", using: :btree
  add_index "admin_announcement_dismissals", ["user_id"], name: "index_admin_announcement_dismissals_on_user_id", using: :btree

  create_table "admin_announcements", force: :cascade do |t|
    t.text     "message",    limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_announcements", ["end_at"], name: "index_admin_announcements_on_end_at", using: :btree
  add_index "admin_announcements", ["start_at", "end_at"], name: "[:admin_announcements_for_index]", using: :btree
  add_index "admin_announcements", ["start_at"], name: "index_admin_announcements_on_start_at", using: :btree

  create_table "admin_authority_groups", force: :cascade do |t|
    t.string   "auth_group_name",        limit: 255,   null: false
    t.text     "description",            limit: 65535
    t.string   "controlling_class_name", limit: 255
    t.string   "associated_group_pid",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "authorized_usernames",   limit: 255
  end

  add_index "admin_authority_groups", ["associated_group_pid"], name: "index_admin_authority_groups_on_associated_group_pid", using: :btree
  add_index "admin_authority_groups", ["auth_group_name"], name: "index_admin_authority_groups_on_auth_group_name", unique: true, using: :btree

  create_table "admin_user_whitelists", force: :cascade do |t|
    t.string   "username",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_user_whitelists", ["username"], name: "index_admin_user_whitelists_on_username", unique: true, using: :btree

  create_table "api_access_tokens", id: false, force: :cascade do |t|
    t.string   "sha",        limit: 255, null: false
    t.string   "issued_by",  limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "work_id",    limit: 255
  end

  add_index "api_access_tokens", ["sha"], name: "index_api_access_tokens_on_sha", unique: true, using: :btree
  add_index "api_access_tokens", ["user_id"], name: "index_api_access_tokens_on_user_id", using: :btree

  create_table "api_transaction_files", force: :cascade do |t|
    t.string   "trx_id",       limit: 255, null: false
    t.string   "file_id",      limit: 255, null: false
    t.integer  "file_seq_nbr", limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_transaction_files", ["trx_id", "file_id", "file_seq_nbr"], name: "unique_index", unique: true, using: :btree
  add_index "api_transaction_files", ["trx_id", "file_id"], name: "index_api_transaction_files_on_trx_id_and_file_id", using: :btree

  create_table "api_transactions", id: false, force: :cascade do |t|
    t.string   "trx_id",     limit: 255, null: false
    t.string   "trx_status", limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "work_id",    limit: 255
  end

  add_index "api_transactions", ["trx_id"], name: "index_api_transactions_on_trx_id", unique: true, using: :btree
  add_index "api_transactions", ["user_id", "trx_id"], name: "index_api_transactions_on_user_id_and_trx_id", unique: true, using: :btree
  add_index "api_transactions", ["user_id"], name: "index_api_transactions_on_user_id", using: :btree

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",     limit: 4,   null: false
    t.string   "document_id", limit: 255
    t.string   "title",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type",   limit: 255
  end

  add_index "bookmarks", ["user_id", "user_type"], name: "index_bookmarks_on_user_id_and_user_type", using: :btree

  create_table "checksum_audit_logs", force: :cascade do |t|
    t.string   "pid",             limit: 255
    t.string   "dsid",            limit: 255
    t.string   "version",         limit: 255
    t.integer  "pass",            limit: 4
    t.string   "expected_result", limit: 255
    t.string   "actual_result",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "checksum_audit_logs", ["pid", "dsid"], name: "by_pid_and_dsid", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.string   "subject",    limit: 255, default: ""
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "devise_multi_auth_authentications", force: :cascade do |t|
    t.integer  "user_id",       limit: 4,   null: false
    t.string   "provider",      limit: 255, null: false
    t.string   "uid",           limit: 255, null: false
    t.string   "access_token",  limit: 255
    t.string   "refresh_token", limit: 255
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "devise_multi_auth_authentications", ["provider", "uid"], name: "index_devise_multi_auth_authentications_on_provider_and_uid", unique: true, using: :btree

  create_table "domain_terms", force: :cascade do |t|
    t.string "model", limit: 255
    t.string "term",  limit: 255
  end

  add_index "domain_terms", ["model", "term"], name: "terms_by_model_and_term", using: :btree

  create_table "domain_terms_local_authorities", id: false, force: :cascade do |t|
    t.integer "domain_term_id",     limit: 4
    t.integer "local_authority_id", limit: 4
  end

  add_index "domain_terms_local_authorities", ["domain_term_id", "local_authority_id"], name: "dtla_by_ids2", using: :btree
  add_index "domain_terms_local_authorities", ["local_authority_id", "domain_term_id"], name: "dtla_by_ids1", using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "followable_id",   limit: 4,                   null: false
    t.string   "followable_type", limit: 255,                 null: false
    t.integer  "follower_id",     limit: 4,                   null: false
    t.string   "follower_type",   limit: 255,                 null: false
    t.boolean  "blocked",                     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followable_id", "followable_type"], name: "fk_followables", using: :btree
  add_index "follows", ["follower_id", "follower_type"], name: "fk_follows", using: :btree

  create_table "harbinger_message_elements", force: :cascade do |t|
    t.integer  "message_id", limit: 4
    t.string   "key",        limit: 255
    t.text     "value",      limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "harbinger_message_elements", ["key"], name: "index_harbinger_message_elements_on_key", using: :btree
  add_index "harbinger_message_elements", ["message_id", "key"], name: "index_harbinger_message_elements_on_message_id_and_key", using: :btree
  add_index "harbinger_message_elements", ["message_id"], name: "index_harbinger_message_elements_on_message_id", using: :btree

  create_table "harbinger_messages", force: :cascade do |t|
    t.string   "reporters",         limit: 255
    t.string   "state",             limit: 32
    t.string   "message_object_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "harbinger_messages", ["message_object_id"], name: "index_harbinger_messages_on_message_object_id", using: :btree
  add_index "harbinger_messages", ["reporters"], name: "index_harbinger_messages_on_reporters", using: :btree
  add_index "harbinger_messages", ["state"], name: "index_harbinger_messages_on_state", using: :btree

  create_table "help_requests", force: :cascade do |t|
    t.string   "view_port",           limit: 255
    t.text     "current_url",         limit: 65535
    t.string   "user_agent",          limit: 255
    t.string   "resolution",          limit: 255
    t.text     "how_can_we_help_you", limit: 65535
    t.integer  "user_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "javascript_enabled"
    t.string   "release_version",     limit: 255
    t.string   "name",                limit: 255
    t.string   "email",               limit: 255
  end

  add_index "help_requests", ["created_at"], name: "index_help_requests_on_created_at", using: :btree
  add_index "help_requests", ["user_id"], name: "index_help_requests_on_user_id", using: :btree

  create_table "local_authorities", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "local_authority_entries", force: :cascade do |t|
    t.integer "local_authority_id", limit: 4
    t.string  "label",              limit: 255
    t.string  "uri",                limit: 255
  end

  add_index "local_authority_entries", ["local_authority_id", "label"], name: "entries_by_term_and_label", using: :btree
  add_index "local_authority_entries", ["local_authority_id", "uri"], name: "entries_by_term_and_uri", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.string   "type",                 limit: 255
    t.text     "body",                 limit: 65535
    t.string   "subject",              limit: 255,   default: ""
    t.integer  "sender_id",            limit: 4
    t.string   "sender_type",          limit: 255
    t.integer  "conversation_id",      limit: 4
    t.boolean  "draft",                              default: false
    t.datetime "updated_at",                                         null: false
    t.datetime "created_at",                                         null: false
    t.integer  "notified_object_id",   limit: 4
    t.string   "notified_object_type", limit: 255
    t.string   "notification_code",    limit: 255
    t.string   "attachment",           limit: 255
  end

  add_index "notifications", ["conversation_id"], name: "index_notifications_on_conversation_id", using: :btree
  add_index "notifications", ["notified_object_id", "notified_object_type"], name: "notifications_notified_object", using: :btree
  add_index "notifications", ["sender_id", "sender_type"], name: "index_notifications_on_sender_id_and_sender_type", using: :btree

  create_table "object_access", primary_key: "access_id", force: :cascade do |t|
    t.datetime "date_accessed"
    t.string   "ip_address",     limit: 255
    t.string   "host_name",      limit: 255
    t.string   "user_agent",     limit: 255
    t.string   "request_method", limit: 255
    t.string   "path_info",      limit: 255
    t.integer  "repo_object_id", limit: 4
    t.integer  "purl_id",        limit: 4
  end

  create_table "orcid_profile_requests", force: :cascade do |t|
    t.integer  "user_id",          limit: 4,     null: false
    t.string   "given_names",      limit: 255,   null: false
    t.string   "family_name",      limit: 255,   null: false
    t.string   "primary_email",    limit: 255,   null: false
    t.string   "orcid_profile_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "response_text",    limit: 65535
    t.string   "response_status",  limit: 255
  end

  create_table "orphan_file_requests", force: :cascade do |t|
    t.string   "user_id",        limit: 255
    t.string   "user_email",     limit: 255
    t.string   "file_id",        limit: 255
    t.string   "work_id",        limit: 255
    t.datetime "completed_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orphan_file_requests", ["user_id"], name: "index_orphan_file_requests_on_user_id", using: :btree

  create_table "proxy_deposit_rights", force: :cascade do |t|
    t.integer  "grantor_id", limit: 4
    t.integer  "grantee_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "proxy_deposit_rights", ["grantee_id"], name: "index_proxy_deposit_rights_on_grantee_id", using: :btree
  add_index "proxy_deposit_rights", ["grantor_id"], name: "index_proxy_deposit_rights_on_grantor_id", using: :btree

  create_table "purl", primary_key: "purl_id", force: :cascade do |t|
    t.integer  "repo_object_id", limit: 4
    t.string   "access_count",   limit: 255
    t.datetime "last_accessed"
    t.string   "source_app",     limit: 255
    t.datetime "date_created"
  end

  create_table "receipts", force: :cascade do |t|
    t.integer  "receiver_id",     limit: 4
    t.string   "receiver_type",   limit: 255
    t.integer  "notification_id", limit: 4,                   null: false
    t.boolean  "is_read",                     default: false
    t.boolean  "trashed",                     default: false
    t.boolean  "deleted",                     default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "receipts", ["notification_id"], name: "index_receipts_on_notification_id", using: :btree
  add_index "receipts", ["receiver_id", "receiver_type"], name: "index_receipts_on_receiver_id_and_receiver_type", using: :btree

  create_table "repo_managers", force: :cascade do |t|
    t.string   "username",   limit: 255
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repo_managers", ["username"], name: "index_repo_managers_on_username", using: :btree

  create_table "repo_object", primary_key: "repo_object_id", force: :cascade do |t|
    t.string   "filename",      limit: 255
    t.string   "url",           limit: 255
    t.datetime "date_added"
    t.string   "add_source_ip", limit: 255
    t.datetime "date_modified"
    t.string   "information",   limit: 255
  end

  create_table "searches", force: :cascade do |t|
    t.text     "query_params", limit: 65535
    t.integer  "user_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_type",    limit: 255
  end

  add_index "searches", ["user_id", "user_type"], name: "index_searches_on_user_id_and_user_type", using: :btree
  add_index "searches", ["user_id"], name: "index_searches_on_user_id", using: :btree

  create_table "single_use_links", force: :cascade do |t|
    t.string   "downloadKey", limit: 255
    t.string   "path",        limit: 255
    t.string   "itemId",      limit: 255
    t.datetime "expires"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subject_local_authority_entries", force: :cascade do |t|
    t.string "label",      limit: 255
    t.string "lowerLabel", limit: 255
    t.string "url",        limit: 255
  end

  add_index "subject_local_authority_entries", ["lowerLabel"], name: "entries_by_lower_label", using: :btree

  create_table "temporary_access_tokens", id: false, force: :cascade do |t|
    t.string   "sha",         limit: 255, null: false
    t.string   "noid",        limit: 255
    t.string   "issued_by",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expiry_date"
  end

  add_index "temporary_access_tokens", ["expiry_date"], name: "index_temporary_access_tokens_on_expiry_date", using: :btree
  add_index "temporary_access_tokens", ["noid"], name: "index_temporary_access_tokens_on_noid", using: :btree
  add_index "temporary_access_tokens", ["sha", "noid", "expiry_date"], name: "index_temporary_access_tokens_on_sha_and_noid_and_expiry_date", unique: true, using: :btree
  add_index "temporary_access_tokens", ["sha"], name: "index_temporary_access_tokens_on_sha", unique: true, using: :btree

  create_table "trophies", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.string   "generic_file_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trophies", ["user_id"], name: "index_trophies_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                                limit: 255,   default: "",    null: false
    t.string   "encrypted_password",                   limit: 255,   default: "",    null: false
    t.string   "reset_password_token",                 limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        limit: 4,     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",                   limit: 255
    t.string   "last_sign_in_ip",                      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "guest",                                              default: false
    t.string   "username",                             limit: 255,                   null: false
    t.string   "facebook_handle",                      limit: 255
    t.string   "twitter_handle",                       limit: 255
    t.string   "googleplus_handle",                    limit: 255
    t.string   "name",                                 limit: 255
    t.string   "address",                              limit: 255
    t.string   "admin_area",                           limit: 255
    t.string   "department",                           limit: 255
    t.string   "title",                                limit: 255
    t.string   "office",                               limit: 255
    t.string   "chat_id",                              limit: 255
    t.string   "website",                              limit: 255
    t.string   "affiliation",                          limit: 255
    t.string   "telephone",                            limit: 255
    t.string   "avatar_file_name",                     limit: 255
    t.string   "avatar_content_type",                  limit: 255
    t.integer  "avatar_file_size",                     limit: 4
    t.datetime "avatar_updated_at"
    t.text     "group_list",                           limit: 65535
    t.datetime "groups_last_update"
    t.boolean  "agreed_to_terms_of_service",                         default: false
    t.string   "repository_id",                        limit: 255
    t.boolean  "user_does_not_require_profile_update",               default: false
    t.string   "researcher_id",                        limit: 255
    t.string   "scopus_id",                            limit: 255
    t.string   "orcid_id",                             limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["repository_id"], name: "index_users_on_repository_id", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "version_committers", force: :cascade do |t|
    t.string   "obj_id",          limit: 255
    t.string   "datastream_id",   limit: 255
    t.string   "version_id",      limit: 255
    t.string   "committer_login", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "notifications", "conversations", name: "notifications_on_conversation_id"
  add_foreign_key "receipts", "notifications", name: "receipts_on_notification_id"
end
