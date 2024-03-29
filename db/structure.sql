--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: ci_lower_bound(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ci_lower_bound(ups integer, downs integer) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
    select (case($1 + $2) when 0 then 0
            else (($1 + 1.9208) / ($1 + $2) - 
                   1.96 * SQRT(($1 * $2) / ($1 + $2) + 0.9604) / 
                          ($1 + $2)) / (1 + 3.8416 / ($1 + $2)) end)
$_$;


--
-- Name: hot_score(integer, integer, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hot_score(ups integer, downs integer, date timestamp with time zone) RETURNS numeric
    LANGUAGE sql IMMUTABLE
    AS $_$
        select round(cast(log(greatest(abs($1 - $2), 1)) * sign($1 - $2) + 
          (date_part('epoch', $3) - 1134028003) / 45000.0 as numeric), 7)
      $_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE activities (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    trackable_id uuid,
    trackable_type character varying(255),
    owner_id uuid,
    owner_type character varying(255),
    key character varying(255),
    parameters text,
    recipient_id uuid,
    recipient_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    notified boolean DEFAULT false,
    notification_error character varying(255)
);


--
-- Name: admins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admins (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    username character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admins_id_seq OWNED BY admins.id;


--
-- Name: card_images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE card_images (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    original_image_url character varying(255) NOT NULL,
    caption text,
    card_id uuid NOT NULL,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    image character varying(255),
    image_processing boolean DEFAULT false
);


--
-- Name: cards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cards (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    stack_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    short_id integer NOT NULL,
    score integer DEFAULT 0,
    flags_count integer DEFAULT 0,
    comments_count integer DEFAULT 0,
    up_score integer DEFAULT 0,
    down_score integer DEFAULT 0,
    source character varying(255) NOT NULL
);


--
-- Name: cards_short_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cards_short_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_short_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cards_short_id_seq OWNED BY cards.short_id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    body text,
    mentions hstore,
    replying_id uuid,
    card_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    score integer DEFAULT 0,
    flags_count integer DEFAULT 0,
    up_score integer DEFAULT 0,
    down_score integer DEFAULT 0
);


--
-- Name: deleted_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE deleted_users (
    email character varying(255),
    encrypted_password character varying(255),
    username character varying(255),
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    avatar_url character varying(255),
    id uuid NOT NULL,
    facebook_token character varying(255),
    facebook_id character varying(255),
    location character varying(255),
    flags_count integer,
    score integer,
    deleted_at timestamp without time zone,
    bio text,
    unseen_notifications_count integer DEFAULT 0 NOT NULL
);


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE devices (
    access_token character varying(32) NOT NULL,
    device_type character varying(16),
    last_sign_in_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid,
    push_token character varying(255),
    sns_arn character varying(255)
);


--
-- Name: flags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE flags (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    flaggable_id uuid NOT NULL,
    flaggable_type character varying(255) NOT NULL,
    user_id uuid NOT NULL,
    kind integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: networks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE networks (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    provider character varying(255) NOT NULL,
    uid character varying(255) NOT NULL,
    token text NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    secret character varying(255),
    username character varying(255)
);


--
-- Name: notification_senders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notification_senders (
    id integer NOT NULL,
    notification_id uuid NOT NULL,
    user_id uuid NOT NULL,
    username character varying(255) NOT NULL
);


--
-- Name: notification_senders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notification_senders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_senders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notification_senders_id_seq OWNED BY notification_senders.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    subject_type character varying(255) NOT NULL,
    action character varying(255) NOT NULL,
    seen boolean DEFAULT false,
    read boolean DEFAULT false,
    sent_at timestamp without time zone,
    extra character varying(255),
    senders_count integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: old_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE old_notifications (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    subject_type character varying(255) NOT NULL,
    action character varying(255) NOT NULL,
    senders hstore,
    read_at timestamp without time zone,
    sent_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    seen_at timestamp without time zone,
    extra hstore
);


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pages (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    slug character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    content text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: reputations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reputations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    min_score integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: reputations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reputations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reputations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reputations_id_seq OWNED BY reputations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    value character varying(255),
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: stack_stats; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stack_stats (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    date date NOT NULL,
    stack_id uuid NOT NULL,
    subscriptions integer DEFAULT 0,
    unsubscriptions integer DEFAULT 0
);


--
-- Name: stacks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stacks (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    protected boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id uuid,
    description text,
    subscriptions_count integer DEFAULT 0
);


--
-- Name: stats; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stats (
    date date NOT NULL,
    users integer DEFAULT 0,
    deleted_users integer DEFAULT 0,
    stacks integer DEFAULT 0,
    subscriptions integer DEFAULT 0,
    cards integer DEFAULT 0,
    comments integer DEFAULT 0,
    flagged_users integer DEFAULT 0,
    flagged_cards integer DEFAULT 0,
    flagged_comments integer DEFAULT 0
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subscriptions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    stack_id uuid NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    username character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    avatar_url character varying(255),
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    facebook_token text,
    facebook_id character varying(255),
    location character varying(255),
    flags_count integer DEFAULT 0,
    score integer DEFAULT 0,
    deleted_at timestamp without time zone,
    bio text,
    unseen_notifications_count integer DEFAULT 0 NOT NULL
);


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE votes (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    votable_id uuid NOT NULL,
    votable_type character varying(255) NOT NULL,
    user_id uuid NOT NULL,
    flag boolean DEFAULT true,
    weight integer DEFAULT 1,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admins ALTER COLUMN id SET DEFAULT nextval('admins_id_seq'::regclass);


--
-- Name: short_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cards ALTER COLUMN short_id SET DEFAULT nextval('cards_short_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notification_senders ALTER COLUMN id SET DEFAULT nextval('notification_senders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reputations ALTER COLUMN id SET DEFAULT nextval('reputations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: card_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY card_images
    ADD CONSTRAINT card_images_pkey PRIMARY KEY (id);


--
-- Name: cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: deleted_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY deleted_users
    ADD CONSTRAINT deleted_users_pkey PRIMARY KEY (id);


--
-- Name: devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY flags
    ADD CONSTRAINT flags_pkey PRIMARY KEY (id);


--
-- Name: networks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY networks
    ADD CONSTRAINT networks_pkey PRIMARY KEY (id);


--
-- Name: notification_senders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notification_senders
    ADD CONSTRAINT notification_senders_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY old_notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey1; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey1 PRIMARY KEY (id);


--
-- Name: pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- Name: reputations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reputations
    ADD CONSTRAINT reputations_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: stack_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stack_stats
    ADD CONSTRAINT stack_stats_pkey PRIMARY KEY (id);


--
-- Name: stacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stacks
    ADD CONSTRAINT stacks_pkey PRIMARY KEY (id);


--
-- Name: stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stats
    ADD CONSTRAINT stats_pkey PRIMARY KEY (date);


--
-- Name: subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: index_activities_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_owner_id_and_owner_type ON activities USING btree (owner_id, owner_type);


--
-- Name: index_activities_on_recipient_id_and_recipient_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_recipient_id_and_recipient_type ON activities USING btree (recipient_id, recipient_type);


--
-- Name: index_activities_on_trackable_id_and_trackable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_activities_on_trackable_id_and_trackable_type ON activities USING btree (trackable_id, trackable_type);


--
-- Name: index_admins_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_email ON admins USING btree (email);


--
-- Name: index_admins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_reset_password_token ON admins USING btree (reset_password_token);


--
-- Name: index_admins_on_username; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_username ON admins USING btree (username);


--
-- Name: index_card_images_on_card_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_card_images_on_card_id ON card_images USING btree (card_id);


--
-- Name: index_cards_on_score; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cards_on_score ON cards USING btree (score);


--
-- Name: index_cards_on_short_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cards_on_short_id ON cards USING btree (short_id);


--
-- Name: index_cards_on_stack_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cards_on_stack_id ON cards USING btree (stack_id);


--
-- Name: index_cards_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cards_on_user_id ON cards USING btree (user_id);


--
-- Name: index_comments_on_card_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_card_id ON comments USING btree (card_id);


--
-- Name: index_comments_on_replying_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_replying_id ON comments USING btree (replying_id);


--
-- Name: index_comments_on_score; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_score ON comments USING btree (score);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_comments_rank; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_rank ON comments USING btree (ci_lower_bound(up_score, down_score));


--
-- Name: index_devices_on_access_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_devices_on_access_token ON devices USING btree (access_token);


--
-- Name: index_flags_on_flaggable_id_and_flaggable_type_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_flags_on_flaggable_id_and_flaggable_type_and_user_id ON flags USING btree (flaggable_id, flaggable_type, user_id);


--
-- Name: index_networks_on_provider_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_networks_on_provider_and_user_id ON networks USING btree (provider, user_id);


--
-- Name: index_networks_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_networks_on_uid ON networks USING btree (uid);


--
-- Name: index_notification_senders_on_notification_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notification_senders_on_notification_id ON notification_senders USING btree (notification_id);


--
-- Name: index_notification_senders_on_notification_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_notification_senders_on_notification_id_and_user_id ON notification_senders USING btree (notification_id, user_id);


--
-- Name: index_notifications_on_action; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_action ON notifications USING btree (action);


--
-- Name: index_notifications_on_subject_id_and_subject_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_subject_id_and_subject_type ON notifications USING btree (subject_id, subject_type);


--
-- Name: index_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_user_id ON notifications USING btree (user_id);


--
-- Name: index_old_notifications_on_read_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_old_notifications_on_read_at ON old_notifications USING btree (read_at);


--
-- Name: index_old_notifications_on_seen_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_old_notifications_on_seen_at ON old_notifications USING btree (seen_at);


--
-- Name: index_old_notifications_on_subject_id_and_subject_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_old_notifications_on_subject_id_and_subject_type ON old_notifications USING btree (subject_id, subject_type);


--
-- Name: index_old_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_old_notifications_on_user_id ON old_notifications USING btree (user_id);


--
-- Name: index_pages_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_pages_on_slug ON pages USING btree (slug);


--
-- Name: index_reputations_on_min_score; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_reputations_on_min_score ON reputations USING btree (min_score);


--
-- Name: index_reputations_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_reputations_on_name ON reputations USING btree (name);


--
-- Name: index_settings_on_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_key ON settings USING btree (key);


--
-- Name: index_stack_stats_on_date_and_stack_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_stack_stats_on_date_and_stack_id ON stack_stats USING btree (date, stack_id);


--
-- Name: index_stacks_on_lowercase_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_stacks_on_lowercase_name ON stacks USING btree (lower((name)::text));


--
-- Name: index_subscriptions_on_user_id_and_stack_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_subscriptions_on_user_id_and_stack_id ON subscriptions USING btree (user_id, stack_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_deleted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_deleted_at ON users USING btree (deleted_at);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_facebook_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_facebook_id ON users USING btree (facebook_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_votes_on_votable_id_and_votable_type_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_votes_on_votable_id_and_votable_type_and_user_id ON votes USING btree (votable_id, votable_type, user_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140611174051');

INSERT INTO schema_migrations (version) VALUES ('20140611174058');

INSERT INTO schema_migrations (version) VALUES ('20140616135102');

INSERT INTO schema_migrations (version) VALUES ('20140618174429');

INSERT INTO schema_migrations (version) VALUES ('20140618174430');

INSERT INTO schema_migrations (version) VALUES ('20140619175323');

INSERT INTO schema_migrations (version) VALUES ('20140623121307');

INSERT INTO schema_migrations (version) VALUES ('20140623123043');

INSERT INTO schema_migrations (version) VALUES ('20140623175636');

INSERT INTO schema_migrations (version) VALUES ('20140624124228');

INSERT INTO schema_migrations (version) VALUES ('20140625165821');

INSERT INTO schema_migrations (version) VALUES ('20140626134008');

INSERT INTO schema_migrations (version) VALUES ('20140626164514');

INSERT INTO schema_migrations (version) VALUES ('20140626190935');

INSERT INTO schema_migrations (version) VALUES ('20140626204658');

INSERT INTO schema_migrations (version) VALUES ('20140630172909');

INSERT INTO schema_migrations (version) VALUES ('20140630191953');

INSERT INTO schema_migrations (version) VALUES ('20140702130406');

INSERT INTO schema_migrations (version) VALUES ('20140702144150');

INSERT INTO schema_migrations (version) VALUES ('20140702154106');

INSERT INTO schema_migrations (version) VALUES ('20140702160258');

INSERT INTO schema_migrations (version) VALUES ('20140702164640');

INSERT INTO schema_migrations (version) VALUES ('20140703170850');

INSERT INTO schema_migrations (version) VALUES ('20140703180441');

INSERT INTO schema_migrations (version) VALUES ('20140703184814');

INSERT INTO schema_migrations (version) VALUES ('20140703195528');

INSERT INTO schema_migrations (version) VALUES ('20140708122457');

INSERT INTO schema_migrations (version) VALUES ('20140711191432');

INSERT INTO schema_migrations (version) VALUES ('20140716132016');

INSERT INTO schema_migrations (version) VALUES ('20140716201104');

INSERT INTO schema_migrations (version) VALUES ('20140717140507');

INSERT INTO schema_migrations (version) VALUES ('20140717202402');

INSERT INTO schema_migrations (version) VALUES ('20140721202339');

INSERT INTO schema_migrations (version) VALUES ('20140722133509');

INSERT INTO schema_migrations (version) VALUES ('20140723142831');

INSERT INTO schema_migrations (version) VALUES ('20140724132440');

INSERT INTO schema_migrations (version) VALUES ('20140725132444');

INSERT INTO schema_migrations (version) VALUES ('20140725210008');

INSERT INTO schema_migrations (version) VALUES ('20140728134801');

INSERT INTO schema_migrations (version) VALUES ('20140730191712');

INSERT INTO schema_migrations (version) VALUES ('20140731132617');

INSERT INTO schema_migrations (version) VALUES ('20140731144746');

INSERT INTO schema_migrations (version) VALUES ('20140731162847');

INSERT INTO schema_migrations (version) VALUES ('20140731190126');

INSERT INTO schema_migrations (version) VALUES ('20140825201347');

INSERT INTO schema_migrations (version) VALUES ('20140901123045');

INSERT INTO schema_migrations (version) VALUES ('20140901183704');

INSERT INTO schema_migrations (version) VALUES ('20140911201247');

INSERT INTO schema_migrations (version) VALUES ('20140922185725');

INSERT INTO schema_migrations (version) VALUES ('20140924142303');

INSERT INTO schema_migrations (version) VALUES ('20140929195912');

INSERT INTO schema_migrations (version) VALUES ('20141002143354');

INSERT INTO schema_migrations (version) VALUES ('20141016195713');

INSERT INTO schema_migrations (version) VALUES ('20141202120442');

INSERT INTO schema_migrations (version) VALUES ('20150106202113');

INSERT INTO schema_migrations (version) VALUES ('20150407215135');

INSERT INTO schema_migrations (version) VALUES ('20150410175644');

