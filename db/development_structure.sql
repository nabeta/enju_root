--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE activities (
    id integer NOT NULL,
    user_id integer,
    source_id integer,
    title text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: amazon_products; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE amazon_products (
    id integer NOT NULL,
    asin character varying(255),
    xml text,
    amazonable_id integer DEFAULT 0 NOT NULL,
    amazonable_type character varying(15) DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: answers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    user_id integer,
    question_id integer,
    body text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: apps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE apps (
    id integer NOT NULL,
    source_url character varying(255),
    title character varying(255),
    description text,
    directory_title character varying(255),
    title_url character varying(255),
    author character varying(255),
    author_email character varying(255),
    author_affiliation character varying(255),
    author_location character varying(255),
    screenshot character varying(255),
    thumbnail character varying(255),
    height integer,
    width integer,
    scaling boolean,
    scrolling boolean,
    singleton boolean,
    author_photo character varying(255),
    author_aboutme text,
    author_link character varying(255),
    author_quote text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: attachment_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE attachment_files (
    id integer NOT NULL,
    attachable_id integer,
    attachable_type character varying(255),
    size integer,
    content_type character varying(255),
    filename text,
    height integer,
    width integer,
    parent_id integer,
    thumbnail character varying(255),
    db_file_id integer,
    fulltext text,
    sha1_hash character varying(255),
    type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: available_manifestation_forms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE available_manifestation_forms (
    id integer NOT NULL,
    user_group_id integer DEFAULT 1 NOT NULL,
    manifestation_form_id integer DEFAULT 1 NOT NULL,
    loan_limit integer DEFAULT 0 NOT NULL,
    loan_period integer DEFAULT 0 NOT NULL,
    loan_renewal_limit integer DEFAULT 0 NOT NULL,
    reservation_limit integer DEFAULT 0 NOT NULL,
    reservation_expire_days integer DEFAULT 7 NOT NULL,
    due_date_before_closed boolean DEFAULT false NOT NULL,
    fixed_due_date timestamp without time zone,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: banner_advertisements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE banner_advertisements (
    id integer NOT NULL,
    name text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: baskets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE baskets (
    id integer NOT NULL,
    user_id integer,
    note text,
    type character varying(255),
    lock_version integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: bdrb_job_queues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bdrb_job_queues (
    id integer NOT NULL,
    args bytea,
    worker_name character varying(255),
    worker_method character varying(255),
    job_key character varying(255),
    taken integer,
    finished integer,
    timeout integer,
    priority integer,
    submitted_at timestamp without time zone,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    archived_at timestamp without time zone,
    scheduled_at timestamp without time zone,
    tag character varying(255),
    submitter_info character varying(255),
    runner_info character varying(255),
    worker_key character varying(255)
);


--
-- Name: bookmarked_resources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bookmarked_resources (
    id integer NOT NULL,
    title text,
    url character varying(255) NOT NULL,
    manifestation_id integer NOT NULL,
    bookmarks_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bookmarks (
    id integer NOT NULL,
    user_id integer NOT NULL,
    bookmarked_resource_id integer NOT NULL,
    note text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bookstores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bookstores (
    id integer NOT NULL,
    name text NOT NULL,
    address text,
    note text,
    telephone_number character varying(255),
    fax_number character varying(255),
    "position" integer,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: checked_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE checked_items (
    id integer NOT NULL,
    item_id integer NOT NULL,
    basket_id integer NOT NULL,
    due_date timestamp without time zone NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: checkins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE checkins (
    id integer NOT NULL,
    item_id integer NOT NULL,
    librarian_id integer,
    basket_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: checkouts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE checkouts (
    id integer NOT NULL,
    user_id integer,
    item_id integer NOT NULL,
    checkin_id integer,
    librarian_id integer,
    basket_id integer,
    due_date timestamp without time zone,
    loan_renewal_count integer DEFAULT 0 NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: circulation_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE circulation_statuses (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: classification_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE classification_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: classifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE classifications (
    id integer NOT NULL,
    parent_id integer,
    category character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    note text,
    classification_type_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    title character varying(50) DEFAULT ''::character varying,
    comment text DEFAULT ''::text,
    created_at timestamp without time zone NOT NULL,
    commentable_id integer DEFAULT 0 NOT NULL,
    commentable_type character varying(15) DEFAULT ''::character varying NOT NULL,
    user_id integer DEFAULT 0 NOT NULL
);


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE conversations (
    id integer NOT NULL,
    subject character varying(255) DEFAULT ''::character varying,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: creates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE creates (
    id integer NOT NULL,
    patron_id integer NOT NULL,
    work_id integer NOT NULL,
    "position" integer,
    type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: db_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE db_files (
    id integer NOT NULL,
    data bytea,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: donations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE donations (
    id integer NOT NULL,
    patron_id integer,
    item_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: embodies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE embodies (
    id integer NOT NULL,
    expression_id integer NOT NULL,
    manifestation_id integer NOT NULL,
    type character varying(255),
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: event_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE event_categories (
    id integer NOT NULL,
    name character varying(255),
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    date timestamp without time zone,
    library_id integer DEFAULT 1 NOT NULL,
    event_category_id integer DEFAULT 1 NOT NULL,
    title character varying(255),
    note text,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: exemplifies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE exemplifies (
    id integer NOT NULL,
    manifestation_id integer NOT NULL,
    item_id integer NOT NULL,
    type character varying(255),
    "position" integer,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: expression_forms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE expression_forms (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: expression_merge_lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE expression_merge_lists (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: expression_merges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE expression_merges (
    id integer NOT NULL,
    expression_id integer NOT NULL,
    expression_merge_list_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: expressions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE expressions (
    id integer NOT NULL,
    parent_id integer,
    original_title text NOT NULL,
    title_transcription text,
    title_alternative text,
    summarization text,
    context text,
    language_id integer DEFAULT 1 NOT NULL,
    expression_form_id integer DEFAULT 1 NOT NULL,
    sequencing_pattern character varying(255),
    frequency_of_issue_id integer DEFAULT 1 NOT NULL,
    serial boolean DEFAULT false NOT NULL,
    issn character varying(255),
    note text,
    performs_count integer DEFAULT 0 NOT NULL,
    embodies_count integer DEFAULT 0 NOT NULL,
    resource_has_subjects_count integer DEFAULT 0 NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: frequency_of_issues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE frequency_of_issues (
    id integer NOT NULL,
    name character varying(255),
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: imported_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE imported_files (
    id integer NOT NULL,
    db_file_id integer,
    parent_id integer,
    thumbnail character varying(255),
    filename character varying(255),
    content_type character varying(255),
    size integer,
    width integer,
    height integer,
    aspect_ratio double precision,
    type character varying(255),
    file_hash character varying(255),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: imported_objects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE imported_objects (
    id integer NOT NULL,
    imported_file_id integer,
    importable_id integer,
    importable_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inter_library_loans; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inter_library_loans (
    id integer NOT NULL,
    item_id integer NOT NULL,
    borrowing_library_id integer NOT NULL,
    shipped_at timestamp without time zone,
    received_at timestamp without time zone,
    return_shipped_at timestamp without time zone,
    return_received_at timestamp without time zone,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: item_has_use_restrictions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE item_has_use_restrictions (
    id integer NOT NULL,
    item_id integer,
    use_restriction_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE items (
    id integer NOT NULL,
    parent_id integer,
    call_number character varying(255),
    item_identifier character varying(255),
    local_filename character varying(255),
    circulation_status_id integer DEFAULT 5 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    shelf_id integer DEFAULT 1 NOT NULL,
    basket_id integer,
    use_restriction_id integer DEFAULT 1 NOT NULL,
    include_supplements boolean DEFAULT false NOT NULL,
    checkouts_count integer DEFAULT 0 NOT NULL,
    owns_count integer DEFAULT 0 NOT NULL,
    resource_has_subjects_count integer DEFAULT 0 NOT NULL,
    note text,
    url character varying(255),
    lock_version integer DEFAULT 0 NOT NULL
);


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE languages (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: libraries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE libraries (
    id integer NOT NULL,
    patron_id integer,
    name text NOT NULL,
    shortname character varying(255) NOT NULL,
    short_display_name character varying(255) NOT NULL,
    address text,
    telephone_number_1 character varying(255),
    telephone_number_2 character varying(255),
    fax_number character varying(255),
    lat double precision,
    lng double precision,
    note text,
    call_number_rows integer DEFAULT 1 NOT NULL,
    library_group_id integer DEFAULT 1 NOT NULL,
    users_count integer DEFAULT 0 NOT NULL,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: library_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE library_groups (
    id integer NOT NULL,
    name text NOT NULL,
    shortname character varying(255) NOT NULL,
    time_zone character varying(255),
    amazon_accessed_at timestamp without time zone,
    news_feed_url character varying(255),
    news_feed_xml text,
    news_feed_accessed_at timestamp without time zone,
    default_days_overdue_report integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: library_has_librarians; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE library_has_librarians (
    id integer NOT NULL,
    library_id integer NOT NULL,
    librarian_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: logged_exceptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE logged_exceptions (
    id integer NOT NULL,
    exception_class character varying(255),
    controller_name character varying(255),
    action_name character varying(255),
    message text,
    backtrace text,
    environment text,
    request text,
    created_at timestamp without time zone
);


--
-- Name: mail; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mail (
    id integer NOT NULL,
    user_id integer NOT NULL,
    message_id integer NOT NULL,
    conversation_id integer,
    read boolean DEFAULT false,
    trashed boolean DEFAULT false,
    mailbox character varying(25),
    created_at timestamp without time zone NOT NULL
);


--
-- Name: manifestation_forms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE manifestation_forms (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: manifestations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE manifestations (
    id integer NOT NULL,
    parent_id integer,
    original_title text NOT NULL,
    title_alternative text,
    title_transcription text,
    classification_number character varying(255),
    manifestation_identifier character varying(255),
    date_of_publication timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    access_address text,
    series_statement_issn text,
    language_id integer DEFAULT 1 NOT NULL,
    manifestation_form_id integer DEFAULT 1 NOT NULL,
    start_page integer,
    end_page integer,
    height integer,
    width integer,
    depth integer,
    isbn character varying(255),
    price integer,
    filename text,
    content_type character varying(255),
    size integer,
    volume_number_list character varying(255),
    issue_number_list character varying(255),
    serial_number_list character varying(255),
    double_issue_id integer,
    edition integer,
    note text,
    produces_count integer DEFAULT 0 NOT NULL,
    exemplifies_count integer DEFAULT 0 NOT NULL,
    embodies_count integer DEFAULT 0 NOT NULL,
    resource_has_subjects_count integer DEFAULT 0 NOT NULL,
    repository_content boolean DEFAULT false NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL
);


--
-- Name: message_queues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE message_queues (
    id integer NOT NULL,
    sender_id integer,
    receiver_id integer,
    message_template_id integer,
    subject character varying(255),
    body text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: message_templates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE message_templates (
    id integer NOT NULL,
    status character varying(255) NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE messages (
    id integer NOT NULL,
    receiver_deleted boolean,
    receiver_purged boolean,
    sender_deleted boolean,
    sender_purged boolean,
    read_at timestamp without time zone,
    receiver_id integer,
    sender_id integer,
    subject character varying(255) NOT NULL,
    body text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: messages_recipients; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE messages_recipients (
    message_id integer NOT NULL,
    recipient_id integer NOT NULL
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orders (
    id integer NOT NULL,
    title text,
    author text,
    publisher text,
    isbn character varying(255),
    pubdate integer,
    url character varying(255),
    note text,
    purchase_request_id integer,
    bookstore_id integer DEFAULT 1 NOT NULL,
    manifestation_id integer,
    item_id integer,
    price double precision,
    ordered_at timestamp without time zone,
    canceled_at timestamp without time zone,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: owns; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE owns (
    id integer NOT NULL,
    patron_id integer NOT NULL,
    item_id integer NOT NULL,
    type character varying(255),
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: patron_merge_lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE patron_merge_lists (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: patron_merges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE patron_merges (
    id integer NOT NULL,
    patron_id integer NOT NULL,
    patron_merge_list_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: patron_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE patron_types (
    id integer NOT NULL,
    name character varying(255),
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: patrons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE patrons (
    id integer NOT NULL,
    parent_id integer,
    last_name character varying(255),
    middle_name character varying(255),
    first_name character varying(255),
    last_name_transcription character varying(255),
    middle_name_transcription character varying(255),
    first_name_transcription character varying(255),
    corporate_name character varying(255),
    corporate_name_transcription character varying(255),
    full_name text NOT NULL,
    full_name_transcription text,
    full_name_alternative text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    zip_code_1 character varying(255),
    zip_code_2 character varying(255),
    address_1 text,
    address_2 text,
    address_1_note text,
    address_2_note text,
    other_designation text,
    place text,
    date_of_birth timestamp without time zone,
    date_of_death timestamp without time zone,
    language_id integer DEFAULT 1 NOT NULL,
    patron_type_id integer DEFAULT 1 NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL,
    note text,
    creates_count integer DEFAULT 0 NOT NULL,
    performs_count integer DEFAULT 0 NOT NULL,
    produces_count integer DEFAULT 0 NOT NULL,
    owns_count integer DEFAULT 0 NOT NULL,
    resource_has_subjects_count integer DEFAULT 0 NOT NULL
);


--
-- Name: performs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE performs (
    id integer NOT NULL,
    patron_id integer NOT NULL,
    expression_id integer NOT NULL,
    "position" integer,
    type character varying(255),
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: persistences; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE persistences (
    id integer NOT NULL,
    person_id integer,
    app_id integer,
    type character varying(255),
    instance_id character varying(255),
    key character varying(255),
    value character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: produces; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE produces (
    id integer NOT NULL,
    patron_id integer NOT NULL,
    manifestation_id integer NOT NULL,
    "position" integer,
    type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: purchase_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE purchase_requests (
    id integer NOT NULL,
    user_id integer,
    title text,
    author text,
    publisher text,
    isbn character varying(255),
    pubdate integer,
    price character varying(255),
    url character varying(255),
    note text,
    accepted_at timestamp without time zone,
    denied_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE questions (
    id integer NOT NULL,
    user_id integer,
    body text,
    private_question boolean DEFAULT true NOT NULL,
    answers_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: realizes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE realizes (
    id integer NOT NULL,
    work_id integer NOT NULL,
    expression_id integer NOT NULL,
    "position" integer,
    type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: request_status_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE request_status_types (
    id integer NOT NULL,
    name character varying(255),
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: request_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE request_types (
    id integer NOT NULL,
    name character varying(255),
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: reservations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reservations (
    id integer NOT NULL,
    user_id integer NOT NULL,
    manifestation_id integer NOT NULL,
    item_id integer,
    checked_out_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: resource_has_subjects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE resource_has_subjects (
    id integer NOT NULL,
    subject_id integer NOT NULL,
    subjectable_id integer NOT NULL,
    subjectable_type character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255),
    display_name character varying(255),
    note text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles_users (
    role_id integer,
    user_id integer
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: search_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE search_histories (
    id integer NOT NULL,
    user_id integer,
    operation character varying(255) DEFAULT 'searchRetrieve'::character varying,
    version double precision DEFAULT 1.2,
    query character varying(255),
    start_record integer,
    maximum_records integer,
    record_packing character varying(255),
    record_schema character varying(255),
    result_set_ttl integer,
    stylesheet character varying(255),
    extra_request_data character varying(255),
    number_of_records integer DEFAULT 0,
    result_set_id character varying(255),
    result_set_idle_time integer,
    records text,
    next_record_position integer,
    diagnostics text,
    extra_response_data text,
    echoed_search_retrieve_request text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: shelves; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE shelves (
    id integer NOT NULL,
    name character varying(255),
    note text,
    library_id integer DEFAULT 1 NOT NULL,
    web_shelf boolean DEFAULT false NOT NULL,
    items_count integer DEFAULT 0 NOT NULL,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: sitemap_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sitemap_settings (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    xml_location character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sitemap_static_links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sitemap_static_links (
    id integer NOT NULL,
    url character varying(255),
    name character varying(255),
    priority double precision,
    frequency character varying(255),
    section character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sitemap_widgets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sitemap_widgets (
    id integer NOT NULL,
    widget_model character varying(255),
    index_named_route character varying(255),
    frequency_index character varying(255),
    frequency_show character varying(255),
    priority double precision,
    custom_finder character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: subject_as_concepts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subject_as_concepts (
    id integer NOT NULL,
    term text
);


--
-- Name: subject_as_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subject_as_events (
    id integer NOT NULL,
    term text
);


--
-- Name: subject_as_objects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subject_as_objects (
    id integer NOT NULL,
    term text
);


--
-- Name: subject_as_places; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subject_as_places (
    id integer NOT NULL,
    term text
);


--
-- Name: subject_broader_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subject_broader_terms (
    id integer NOT NULL,
    narrower_term_id integer NOT NULL,
    broader_term_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: subject_has_classifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subject_has_classifications (
    id integer NOT NULL,
    subject_id integer NOT NULL,
    classification_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: subject_related_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subject_related_terms (
    id integer NOT NULL,
    subject_id integer NOT NULL,
    related_term_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: subject_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subject_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subjects (
    id integer NOT NULL,
    parent_id integer,
    use_term_id integer,
    term character varying(255),
    term_transcription text,
    subject_type_id integer NOT NULL,
    scoped_note text,
    note text,
    resource_has_subjects_count integer DEFAULT 0 NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id integer NOT NULL,
    user_id integer NOT NULL,
    tag_id integer NOT NULL,
    taggable_id integer NOT NULL,
    taggable_type character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    name_transcription character varying(255),
    taggings_count integer DEFAULT 0 NOT NULL,
    synonym text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: use_restrictions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE use_restrictions (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_groups (
    id integer NOT NULL,
    name text,
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    login character varying(255) NOT NULL,
    name character varying(100) DEFAULT ''::character varying,
    openid_url character varying(255),
    email character varying(255),
    crypted_password character varying(40),
    salt character varying(40),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    remember_token character varying(255),
    remember_token_expires_at timestamp without time zone,
    activation_code character varying(40),
    activated_at timestamp without time zone,
    patron_id integer NOT NULL,
    library_id integer DEFAULT 1 NOT NULL,
    user_group_id integer DEFAULT 1 NOT NULL,
    reservations_count integer DEFAULT 0 NOT NULL,
    expired_at timestamp without time zone,
    locked boolean DEFAULT true NOT NULL,
    libraries_count integer DEFAULT 0 NOT NULL,
    bookmarks_count integer DEFAULT 0 NOT NULL,
    checkouts_count integer DEFAULT 0 NOT NULL,
    checkout_icalendar_token character varying(255),
    questions_count integer DEFAULT 0 NOT NULL,
    answers_count integer DEFAULT 0 NOT NULL,
    answer_rss_token character varying(255),
    duedate_reminder_days integer DEFAULT 1 NOT NULL,
    note text,
    public_bookmark boolean DEFAULT false NOT NULL,
    save_search_history boolean DEFAULT false NOT NULL,
    save_checkout_history boolean DEFAULT false NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL,
    access_role_id integer DEFAULT 1 NOT NULL,
    "integer" integer DEFAULT 1 NOT NULL,
    keyword_list text
);


--
-- Name: work_forms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE work_forms (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    display_name character varying(255),
    note text,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: work_merge_lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE work_merge_lists (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: work_merges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE work_merges (
    id integer NOT NULL,
    work_id integer NOT NULL,
    work_merge_list_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: works; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE works (
    id integer NOT NULL,
    parent_id integer,
    original_title text NOT NULL,
    title_transcription text,
    title_alternative text,
    context text,
    work_form_id integer DEFAULT 1 NOT NULL,
    note text,
    creates_count integer DEFAULT 0 NOT NULL,
    realizes_count integer DEFAULT 0 NOT NULL,
    resource_has_subjects_count integer DEFAULT 0 NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);


--
-- Name: xml_response_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE xml_response_files (
    id integer NOT NULL,
    manifestation_id integer NOT NULL,
    type character varying(255),
    body bytea,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activities_id_seq OWNED BY activities.id;


--
-- Name: amazon_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE amazon_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: amazon_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE amazon_products_id_seq OWNED BY amazon_products.id;


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: apps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE apps_id_seq OWNED BY apps.id;


--
-- Name: attachment_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attachment_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: attachment_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE attachment_files_id_seq OWNED BY attachment_files.id;


--
-- Name: available_manifestation_forms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE available_manifestation_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: available_manifestation_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE available_manifestation_forms_id_seq OWNED BY available_manifestation_forms.id;


--
-- Name: banner_advertisements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE banner_advertisements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: banner_advertisements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE banner_advertisements_id_seq OWNED BY banner_advertisements.id;


--
-- Name: baskets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE baskets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: baskets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE baskets_id_seq OWNED BY baskets.id;


--
-- Name: bdrb_job_queues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bdrb_job_queues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bdrb_job_queues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bdrb_job_queues_id_seq OWNED BY bdrb_job_queues.id;


--
-- Name: bookmarked_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bookmarked_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bookmarked_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bookmarked_resources_id_seq OWNED BY bookmarked_resources.id;


--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bookmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bookmarks_id_seq OWNED BY bookmarks.id;


--
-- Name: bookstores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bookstores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: bookstores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bookstores_id_seq OWNED BY bookstores.id;


--
-- Name: checked_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE checked_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: checked_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE checked_items_id_seq OWNED BY checked_items.id;


--
-- Name: checkins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE checkins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: checkins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE checkins_id_seq OWNED BY checkins.id;


--
-- Name: checkouts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE checkouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: checkouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE checkouts_id_seq OWNED BY checkouts.id;


--
-- Name: circulation_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE circulation_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: circulation_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE circulation_statuses_id_seq OWNED BY circulation_statuses.id;


--
-- Name: classification_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE classification_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: classification_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE classification_types_id_seq OWNED BY classification_types.id;


--
-- Name: classifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE classifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: classifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE classifications_id_seq OWNED BY classifications.id;


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE conversations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE conversations_id_seq OWNED BY conversations.id;


--
-- Name: creates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE creates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: creates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE creates_id_seq OWNED BY creates.id;


--
-- Name: db_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE db_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: db_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE db_files_id_seq OWNED BY db_files.id;


--
-- Name: donations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE donations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: donations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE donations_id_seq OWNED BY donations.id;


--
-- Name: embodies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE embodies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: embodies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE embodies_id_seq OWNED BY embodies.id;


--
-- Name: event_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: event_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_categories_id_seq OWNED BY event_categories.id;


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: exemplifies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE exemplifies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: exemplifies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE exemplifies_id_seq OWNED BY exemplifies.id;


--
-- Name: expression_forms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE expression_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: expression_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE expression_forms_id_seq OWNED BY expression_forms.id;


--
-- Name: expression_merge_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE expression_merge_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: expression_merge_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE expression_merge_lists_id_seq OWNED BY expression_merge_lists.id;


--
-- Name: expression_merges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE expression_merges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: expression_merges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE expression_merges_id_seq OWNED BY expression_merges.id;


--
-- Name: expressions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE expressions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: expressions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE expressions_id_seq OWNED BY expressions.id;


--
-- Name: frequency_of_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE frequency_of_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: frequency_of_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE frequency_of_issues_id_seq OWNED BY frequency_of_issues.id;


--
-- Name: imported_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE imported_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: imported_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE imported_files_id_seq OWNED BY imported_files.id;


--
-- Name: imported_objects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE imported_objects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: imported_objects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE imported_objects_id_seq OWNED BY imported_objects.id;


--
-- Name: inter_library_loans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inter_library_loans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: inter_library_loans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inter_library_loans_id_seq OWNED BY inter_library_loans.id;


--
-- Name: item_has_use_restrictions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE item_has_use_restrictions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: item_has_use_restrictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE item_has_use_restrictions_id_seq OWNED BY item_has_use_restrictions.id;


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE items_id_seq OWNED BY items.id;


--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE languages_id_seq OWNED BY languages.id;


--
-- Name: libraries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE libraries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: libraries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE libraries_id_seq OWNED BY libraries.id;


--
-- Name: library_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE library_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: library_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE library_groups_id_seq OWNED BY library_groups.id;


--
-- Name: library_has_librarians_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE library_has_librarians_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: library_has_librarians_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE library_has_librarians_id_seq OWNED BY library_has_librarians.id;


--
-- Name: logged_exceptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logged_exceptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: logged_exceptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE logged_exceptions_id_seq OWNED BY logged_exceptions.id;


--
-- Name: mail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: mail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mail_id_seq OWNED BY mail.id;


--
-- Name: manifestation_forms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE manifestation_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: manifestation_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE manifestation_forms_id_seq OWNED BY manifestation_forms.id;


--
-- Name: manifestations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE manifestations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: manifestations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE manifestations_id_seq OWNED BY manifestations.id;


--
-- Name: message_queues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE message_queues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: message_queues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE message_queues_id_seq OWNED BY message_queues.id;


--
-- Name: message_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE message_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: message_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE message_templates_id_seq OWNED BY message_templates.id;


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orders_id_seq OWNED BY orders.id;


--
-- Name: owns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE owns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: owns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE owns_id_seq OWNED BY owns.id;


--
-- Name: patron_merge_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE patron_merge_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: patron_merge_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE patron_merge_lists_id_seq OWNED BY patron_merge_lists.id;


--
-- Name: patron_merges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE patron_merges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: patron_merges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE patron_merges_id_seq OWNED BY patron_merges.id;


--
-- Name: patron_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE patron_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: patron_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE patron_types_id_seq OWNED BY patron_types.id;


--
-- Name: patrons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE patrons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: patrons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE patrons_id_seq OWNED BY patrons.id;


--
-- Name: performs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE performs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: performs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE performs_id_seq OWNED BY performs.id;


--
-- Name: persistences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE persistences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: persistences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE persistences_id_seq OWNED BY persistences.id;


--
-- Name: produces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE produces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: produces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE produces_id_seq OWNED BY produces.id;


--
-- Name: purchase_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE purchase_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: purchase_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE purchase_requests_id_seq OWNED BY purchase_requests.id;


--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE questions_id_seq OWNED BY questions.id;


--
-- Name: realizes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE realizes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: realizes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE realizes_id_seq OWNED BY realizes.id;


--
-- Name: request_status_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_status_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: request_status_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE request_status_types_id_seq OWNED BY request_status_types.id;


--
-- Name: request_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: request_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE request_types_id_seq OWNED BY request_types.id;


--
-- Name: reservations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reservations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: reservations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reservations_id_seq OWNED BY reservations.id;


--
-- Name: resource_has_subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE resource_has_subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: resource_has_subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE resource_has_subjects_id_seq OWNED BY resource_has_subjects.id;


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: search_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE search_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: search_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE search_histories_id_seq OWNED BY search_histories.id;


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: shelves_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE shelves_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: shelves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE shelves_id_seq OWNED BY shelves.id;


--
-- Name: sitemap_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sitemap_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: sitemap_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sitemap_settings_id_seq OWNED BY sitemap_settings.id;


--
-- Name: sitemap_static_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sitemap_static_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: sitemap_static_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sitemap_static_links_id_seq OWNED BY sitemap_static_links.id;


--
-- Name: sitemap_widgets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sitemap_widgets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: sitemap_widgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sitemap_widgets_id_seq OWNED BY sitemap_widgets.id;


--
-- Name: subject_as_concepts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subject_as_concepts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: subject_as_concepts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subject_as_concepts_id_seq OWNED BY subject_as_concepts.id;


--
-- Name: subject_as_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subject_as_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: subject_as_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subject_as_events_id_seq OWNED BY subject_as_events.id;


--
-- Name: subject_as_objects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subject_as_objects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: subject_as_objects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subject_as_objects_id_seq OWNED BY subject_as_objects.id;


--
-- Name: subject_as_places_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subject_as_places_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: subject_as_places_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subject_as_places_id_seq OWNED BY subject_as_places.id;


--
-- Name: subject_broader_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subject_broader_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: subject_broader_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subject_broader_terms_id_seq OWNED BY subject_broader_terms.id;


--
-- Name: subject_has_classifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subject_has_classifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: subject_has_classifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subject_has_classifications_id_seq OWNED BY subject_has_classifications.id;


--
-- Name: subject_related_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subject_related_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: subject_related_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subject_related_terms_id_seq OWNED BY subject_related_terms.id;


--
-- Name: subject_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subject_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: subject_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subject_types_id_seq OWNED BY subject_types.id;


--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subjects_id_seq OWNED BY subjects.id;


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: use_restrictions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE use_restrictions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: use_restrictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE use_restrictions_id_seq OWNED BY use_restrictions.id;


--
-- Name: user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_groups_id_seq OWNED BY user_groups.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: work_forms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE work_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: work_forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE work_forms_id_seq OWNED BY work_forms.id;


--
-- Name: work_merge_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE work_merge_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: work_merge_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE work_merge_lists_id_seq OWNED BY work_merge_lists.id;


--
-- Name: work_merges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE work_merges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: work_merges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE work_merges_id_seq OWNED BY work_merges.id;


--
-- Name: works_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE works_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: works_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE works_id_seq OWNED BY works.id;


--
-- Name: xml_response_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE xml_response_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: xml_response_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE xml_response_files_id_seq OWNED BY xml_response_files.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE activities ALTER COLUMN id SET DEFAULT nextval('activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE amazon_products ALTER COLUMN id SET DEFAULT nextval('amazon_products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE apps ALTER COLUMN id SET DEFAULT nextval('apps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE attachment_files ALTER COLUMN id SET DEFAULT nextval('attachment_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE available_manifestation_forms ALTER COLUMN id SET DEFAULT nextval('available_manifestation_forms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE banner_advertisements ALTER COLUMN id SET DEFAULT nextval('banner_advertisements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE baskets ALTER COLUMN id SET DEFAULT nextval('baskets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE bdrb_job_queues ALTER COLUMN id SET DEFAULT nextval('bdrb_job_queues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE bookmarked_resources ALTER COLUMN id SET DEFAULT nextval('bookmarked_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE bookmarks ALTER COLUMN id SET DEFAULT nextval('bookmarks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE bookstores ALTER COLUMN id SET DEFAULT nextval('bookstores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE checked_items ALTER COLUMN id SET DEFAULT nextval('checked_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE checkins ALTER COLUMN id SET DEFAULT nextval('checkins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE checkouts ALTER COLUMN id SET DEFAULT nextval('checkouts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE circulation_statuses ALTER COLUMN id SET DEFAULT nextval('circulation_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE classification_types ALTER COLUMN id SET DEFAULT nextval('classification_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE classifications ALTER COLUMN id SET DEFAULT nextval('classifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE conversations ALTER COLUMN id SET DEFAULT nextval('conversations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE creates ALTER COLUMN id SET DEFAULT nextval('creates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE db_files ALTER COLUMN id SET DEFAULT nextval('db_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE donations ALTER COLUMN id SET DEFAULT nextval('donations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE embodies ALTER COLUMN id SET DEFAULT nextval('embodies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE event_categories ALTER COLUMN id SET DEFAULT nextval('event_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE exemplifies ALTER COLUMN id SET DEFAULT nextval('exemplifies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE expression_forms ALTER COLUMN id SET DEFAULT nextval('expression_forms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE expression_merge_lists ALTER COLUMN id SET DEFAULT nextval('expression_merge_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE expression_merges ALTER COLUMN id SET DEFAULT nextval('expression_merges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE expressions ALTER COLUMN id SET DEFAULT nextval('expressions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE frequency_of_issues ALTER COLUMN id SET DEFAULT nextval('frequency_of_issues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE imported_files ALTER COLUMN id SET DEFAULT nextval('imported_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE imported_objects ALTER COLUMN id SET DEFAULT nextval('imported_objects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE inter_library_loans ALTER COLUMN id SET DEFAULT nextval('inter_library_loans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE item_has_use_restrictions ALTER COLUMN id SET DEFAULT nextval('item_has_use_restrictions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE items ALTER COLUMN id SET DEFAULT nextval('items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE languages ALTER COLUMN id SET DEFAULT nextval('languages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE libraries ALTER COLUMN id SET DEFAULT nextval('libraries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE library_groups ALTER COLUMN id SET DEFAULT nextval('library_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE library_has_librarians ALTER COLUMN id SET DEFAULT nextval('library_has_librarians_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE logged_exceptions ALTER COLUMN id SET DEFAULT nextval('logged_exceptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE mail ALTER COLUMN id SET DEFAULT nextval('mail_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE manifestation_forms ALTER COLUMN id SET DEFAULT nextval('manifestation_forms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE manifestations ALTER COLUMN id SET DEFAULT nextval('manifestations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE message_queues ALTER COLUMN id SET DEFAULT nextval('message_queues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE message_templates ALTER COLUMN id SET DEFAULT nextval('message_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE orders ALTER COLUMN id SET DEFAULT nextval('orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE owns ALTER COLUMN id SET DEFAULT nextval('owns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE patron_merge_lists ALTER COLUMN id SET DEFAULT nextval('patron_merge_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE patron_merges ALTER COLUMN id SET DEFAULT nextval('patron_merges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE patron_types ALTER COLUMN id SET DEFAULT nextval('patron_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE patrons ALTER COLUMN id SET DEFAULT nextval('patrons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE performs ALTER COLUMN id SET DEFAULT nextval('performs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE persistences ALTER COLUMN id SET DEFAULT nextval('persistences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE produces ALTER COLUMN id SET DEFAULT nextval('produces_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE purchase_requests ALTER COLUMN id SET DEFAULT nextval('purchase_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE questions ALTER COLUMN id SET DEFAULT nextval('questions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE realizes ALTER COLUMN id SET DEFAULT nextval('realizes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE request_status_types ALTER COLUMN id SET DEFAULT nextval('request_status_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE request_types ALTER COLUMN id SET DEFAULT nextval('request_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE reservations ALTER COLUMN id SET DEFAULT nextval('reservations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE resource_has_subjects ALTER COLUMN id SET DEFAULT nextval('resource_has_subjects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE search_histories ALTER COLUMN id SET DEFAULT nextval('search_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE shelves ALTER COLUMN id SET DEFAULT nextval('shelves_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE sitemap_settings ALTER COLUMN id SET DEFAULT nextval('sitemap_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE sitemap_static_links ALTER COLUMN id SET DEFAULT nextval('sitemap_static_links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE sitemap_widgets ALTER COLUMN id SET DEFAULT nextval('sitemap_widgets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE subject_as_concepts ALTER COLUMN id SET DEFAULT nextval('subject_as_concepts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE subject_as_events ALTER COLUMN id SET DEFAULT nextval('subject_as_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE subject_as_objects ALTER COLUMN id SET DEFAULT nextval('subject_as_objects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE subject_as_places ALTER COLUMN id SET DEFAULT nextval('subject_as_places_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE subject_broader_terms ALTER COLUMN id SET DEFAULT nextval('subject_broader_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE subject_has_classifications ALTER COLUMN id SET DEFAULT nextval('subject_has_classifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE subject_related_terms ALTER COLUMN id SET DEFAULT nextval('subject_related_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE subject_types ALTER COLUMN id SET DEFAULT nextval('subject_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE subjects ALTER COLUMN id SET DEFAULT nextval('subjects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE use_restrictions ALTER COLUMN id SET DEFAULT nextval('use_restrictions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE user_groups ALTER COLUMN id SET DEFAULT nextval('user_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE work_forms ALTER COLUMN id SET DEFAULT nextval('work_forms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE work_merge_lists ALTER COLUMN id SET DEFAULT nextval('work_merge_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE work_merges ALTER COLUMN id SET DEFAULT nextval('work_merges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE works ALTER COLUMN id SET DEFAULT nextval('works_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE xml_response_files ALTER COLUMN id SET DEFAULT nextval('xml_response_files_id_seq'::regclass);


--
-- Name: activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: amazon_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY amazon_products
    ADD CONSTRAINT amazon_products_pkey PRIMARY KEY (id);


--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: apps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (id);


--
-- Name: attachment_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachment_files
    ADD CONSTRAINT attachment_files_pkey PRIMARY KEY (id);


--
-- Name: available_manifestation_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY available_manifestation_forms
    ADD CONSTRAINT available_manifestation_forms_pkey PRIMARY KEY (id);


--
-- Name: banner_advertisements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY banner_advertisements
    ADD CONSTRAINT banner_advertisements_pkey PRIMARY KEY (id);


--
-- Name: baskets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY baskets
    ADD CONSTRAINT baskets_pkey PRIMARY KEY (id);


--
-- Name: bdrb_job_queues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bdrb_job_queues
    ADD CONSTRAINT bdrb_job_queues_pkey PRIMARY KEY (id);


--
-- Name: bookmarked_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bookmarked_resources
    ADD CONSTRAINT bookmarked_resources_pkey PRIMARY KEY (id);


--
-- Name: bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: bookstores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bookstores
    ADD CONSTRAINT bookstores_pkey PRIMARY KEY (id);


--
-- Name: checked_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checked_items
    ADD CONSTRAINT checked_items_pkey PRIMARY KEY (id);


--
-- Name: checkins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checkins
    ADD CONSTRAINT checkins_pkey PRIMARY KEY (id);


--
-- Name: checkouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY checkouts
    ADD CONSTRAINT checkouts_pkey PRIMARY KEY (id);


--
-- Name: circulation_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY circulation_statuses
    ADD CONSTRAINT circulation_statuses_pkey PRIMARY KEY (id);


--
-- Name: classification_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY classification_types
    ADD CONSTRAINT classification_types_pkey PRIMARY KEY (id);


--
-- Name: classifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY classifications
    ADD CONSTRAINT classifications_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: creates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY creates
    ADD CONSTRAINT creates_pkey PRIMARY KEY (id);


--
-- Name: db_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY db_files
    ADD CONSTRAINT db_files_pkey PRIMARY KEY (id);


--
-- Name: donations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY donations
    ADD CONSTRAINT donations_pkey PRIMARY KEY (id);


--
-- Name: embodies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY embodies
    ADD CONSTRAINT embodies_pkey PRIMARY KEY (id);


--
-- Name: event_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY event_categories
    ADD CONSTRAINT event_categories_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: exemplifies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY exemplifies
    ADD CONSTRAINT exemplifies_pkey PRIMARY KEY (id);


--
-- Name: expression_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY expression_forms
    ADD CONSTRAINT expression_forms_pkey PRIMARY KEY (id);


--
-- Name: expression_merge_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY expression_merge_lists
    ADD CONSTRAINT expression_merge_lists_pkey PRIMARY KEY (id);


--
-- Name: expression_merges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY expression_merges
    ADD CONSTRAINT expression_merges_pkey PRIMARY KEY (id);


--
-- Name: expressions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY expressions
    ADD CONSTRAINT expressions_pkey PRIMARY KEY (id);


--
-- Name: frequency_of_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY frequency_of_issues
    ADD CONSTRAINT frequency_of_issues_pkey PRIMARY KEY (id);


--
-- Name: imported_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY imported_files
    ADD CONSTRAINT imported_files_pkey PRIMARY KEY (id);


--
-- Name: imported_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY imported_objects
    ADD CONSTRAINT imported_objects_pkey PRIMARY KEY (id);


--
-- Name: inter_library_loans_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inter_library_loans
    ADD CONSTRAINT inter_library_loans_pkey PRIMARY KEY (id);


--
-- Name: item_has_use_restrictions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY item_has_use_restrictions
    ADD CONSTRAINT item_has_use_restrictions_pkey PRIMARY KEY (id);


--
-- Name: items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: libraries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY libraries
    ADD CONSTRAINT libraries_pkey PRIMARY KEY (id);


--
-- Name: library_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY library_groups
    ADD CONSTRAINT library_groups_pkey PRIMARY KEY (id);


--
-- Name: library_has_librarians_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY library_has_librarians
    ADD CONSTRAINT library_has_librarians_pkey PRIMARY KEY (id);


--
-- Name: logged_exceptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY logged_exceptions
    ADD CONSTRAINT logged_exceptions_pkey PRIMARY KEY (id);


--
-- Name: mail_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mail
    ADD CONSTRAINT mail_pkey PRIMARY KEY (id);


--
-- Name: manifestation_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY manifestation_forms
    ADD CONSTRAINT manifestation_forms_pkey PRIMARY KEY (id);


--
-- Name: manifestations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY manifestations
    ADD CONSTRAINT manifestations_pkey PRIMARY KEY (id);


--
-- Name: message_queues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY message_queues
    ADD CONSTRAINT message_queues_pkey PRIMARY KEY (id);


--
-- Name: message_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY message_templates
    ADD CONSTRAINT message_templates_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: owns_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY owns
    ADD CONSTRAINT owns_pkey PRIMARY KEY (id);


--
-- Name: patron_merge_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY patron_merge_lists
    ADD CONSTRAINT patron_merge_lists_pkey PRIMARY KEY (id);


--
-- Name: patron_merges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY patron_merges
    ADD CONSTRAINT patron_merges_pkey PRIMARY KEY (id);


--
-- Name: patron_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY patron_types
    ADD CONSTRAINT patron_types_pkey PRIMARY KEY (id);


--
-- Name: patrons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY patrons
    ADD CONSTRAINT patrons_pkey PRIMARY KEY (id);


--
-- Name: performs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY performs
    ADD CONSTRAINT performs_pkey PRIMARY KEY (id);


--
-- Name: persistences_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY persistences
    ADD CONSTRAINT persistences_pkey PRIMARY KEY (id);


--
-- Name: produces_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY produces
    ADD CONSTRAINT produces_pkey PRIMARY KEY (id);


--
-- Name: purchase_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY purchase_requests
    ADD CONSTRAINT purchase_requests_pkey PRIMARY KEY (id);


--
-- Name: questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: realizes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY realizes
    ADD CONSTRAINT realizes_pkey PRIMARY KEY (id);


--
-- Name: request_status_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY request_status_types
    ADD CONSTRAINT request_status_types_pkey PRIMARY KEY (id);


--
-- Name: request_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY request_types
    ADD CONSTRAINT request_types_pkey PRIMARY KEY (id);


--
-- Name: reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (id);


--
-- Name: resource_has_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resource_has_subjects
    ADD CONSTRAINT resource_has_subjects_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: search_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY search_histories
    ADD CONSTRAINT search_histories_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: shelves_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY shelves
    ADD CONSTRAINT shelves_pkey PRIMARY KEY (id);


--
-- Name: sitemap_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sitemap_settings
    ADD CONSTRAINT sitemap_settings_pkey PRIMARY KEY (id);


--
-- Name: sitemap_static_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sitemap_static_links
    ADD CONSTRAINT sitemap_static_links_pkey PRIMARY KEY (id);


--
-- Name: sitemap_widgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sitemap_widgets
    ADD CONSTRAINT sitemap_widgets_pkey PRIMARY KEY (id);


--
-- Name: subject_as_concepts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subject_as_concepts
    ADD CONSTRAINT subject_as_concepts_pkey PRIMARY KEY (id);


--
-- Name: subject_as_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subject_as_events
    ADD CONSTRAINT subject_as_events_pkey PRIMARY KEY (id);


--
-- Name: subject_as_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subject_as_objects
    ADD CONSTRAINT subject_as_objects_pkey PRIMARY KEY (id);


--
-- Name: subject_as_places_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subject_as_places
    ADD CONSTRAINT subject_as_places_pkey PRIMARY KEY (id);


--
-- Name: subject_broader_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subject_broader_terms
    ADD CONSTRAINT subject_broader_terms_pkey PRIMARY KEY (id);


--
-- Name: subject_has_classifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subject_has_classifications
    ADD CONSTRAINT subject_has_classifications_pkey PRIMARY KEY (id);


--
-- Name: subject_related_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subject_related_terms
    ADD CONSTRAINT subject_related_terms_pkey PRIMARY KEY (id);


--
-- Name: subject_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subject_types
    ADD CONSTRAINT subject_types_pkey PRIMARY KEY (id);


--
-- Name: subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: use_restrictions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY use_restrictions
    ADD CONSTRAINT use_restrictions_pkey PRIMARY KEY (id);


--
-- Name: user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: work_forms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY work_forms
    ADD CONSTRAINT work_forms_pkey PRIMARY KEY (id);


--
-- Name: work_merge_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY work_merge_lists
    ADD CONSTRAINT work_merge_lists_pkey PRIMARY KEY (id);


--
-- Name: work_merges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY work_merges
    ADD CONSTRAINT work_merges_pkey PRIMARY KEY (id);


--
-- Name: works_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY works
    ADD CONSTRAINT works_pkey PRIMARY KEY (id);


--
-- Name: xml_response_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY xml_response_files
    ADD CONSTRAINT xml_response_files_pkey PRIMARY KEY (id);


--
-- Name: fk_comments_user; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fk_comments_user ON comments USING btree (user_id);


--
-- Name: index_answers_on_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_question_id ON answers USING btree (question_id);


--
-- Name: index_answers_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_user_id ON answers USING btree (user_id);


--
-- Name: index_attachment_files_on_attachable_id_and_attachable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachment_files_on_attachable_id_and_attachable_type ON attachment_files USING btree (attachable_id, attachable_type);


--
-- Name: index_attachment_files_on_db_file_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachment_files_on_db_file_id ON attachment_files USING btree (db_file_id);


--
-- Name: index_attachment_files_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachment_files_on_parent_id ON attachment_files USING btree (parent_id);


--
-- Name: index_attachment_files_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachment_files_on_type ON attachment_files USING btree (type);


--
-- Name: index_available_manifestation_forms_on_manifestation_form_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_available_manifestation_forms_on_manifestation_form_id ON available_manifestation_forms USING btree (manifestation_form_id);


--
-- Name: index_available_manifestation_forms_on_user_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_available_manifestation_forms_on_user_group_id ON available_manifestation_forms USING btree (user_group_id);


--
-- Name: index_baskets_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_baskets_on_type ON baskets USING btree (type);


--
-- Name: index_baskets_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_baskets_on_user_id ON baskets USING btree (user_id);


--
-- Name: index_bookmarked_resources_on_manifestation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bookmarked_resources_on_manifestation_id ON bookmarked_resources USING btree (manifestation_id);


--
-- Name: index_bookmarked_resources_on_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bookmarked_resources_on_url ON bookmarked_resources USING btree (url);


--
-- Name: index_bookmarks_on_bookmarked_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bookmarks_on_bookmarked_resource_id ON bookmarks USING btree (bookmarked_resource_id);


--
-- Name: index_bookmarks_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bookmarks_on_user_id ON bookmarks USING btree (user_id);


--
-- Name: index_checked_items_on_basket_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_checked_items_on_basket_id ON checked_items USING btree (basket_id);


--
-- Name: index_checked_items_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_checked_items_on_item_id ON checked_items USING btree (item_id);


--
-- Name: index_checkins_on_basket_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_checkins_on_basket_id ON checkins USING btree (basket_id);


--
-- Name: index_checkins_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_checkins_on_item_id ON checkins USING btree (item_id);


--
-- Name: index_checkins_on_librarian_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_checkins_on_librarian_id ON checkins USING btree (librarian_id);


--
-- Name: index_checkouts_on_basket_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_checkouts_on_basket_id ON checkouts USING btree (basket_id);


--
-- Name: index_checkouts_on_checkin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_checkouts_on_checkin_id ON checkouts USING btree (checkin_id);


--
-- Name: index_checkouts_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_checkouts_on_item_id ON checkouts USING btree (item_id);


--
-- Name: index_checkouts_on_item_id_and_basket_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_checkouts_on_item_id_and_basket_id ON checkouts USING btree (item_id, basket_id);


--
-- Name: index_checkouts_on_librarian_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_checkouts_on_librarian_id ON checkouts USING btree (librarian_id);


--
-- Name: index_checkouts_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_checkouts_on_user_id ON checkouts USING btree (user_id);


--
-- Name: index_classifications_on_category; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_classifications_on_category ON classifications USING btree (category);


--
-- Name: index_classifications_on_classification_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_classifications_on_classification_type_id ON classifications USING btree (classification_type_id);


--
-- Name: index_classifications_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_classifications_on_parent_id ON classifications USING btree (parent_id);


--
-- Name: index_creates_on_patron_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_creates_on_patron_id ON creates USING btree (patron_id);


--
-- Name: index_creates_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_creates_on_type ON creates USING btree (type);


--
-- Name: index_creates_on_work_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_creates_on_work_id ON creates USING btree (work_id);


--
-- Name: index_donations_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_donations_on_item_id ON donations USING btree (item_id);


--
-- Name: index_donations_on_patron_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_donations_on_patron_id ON donations USING btree (patron_id);


--
-- Name: index_embodies_on_expression_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_embodies_on_expression_id ON embodies USING btree (expression_id);


--
-- Name: index_embodies_on_manifestation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_embodies_on_manifestation_id ON embodies USING btree (manifestation_id);


--
-- Name: index_embodies_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_embodies_on_type ON embodies USING btree (type);


--
-- Name: index_events_on_event_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_event_category_id ON events USING btree (event_category_id);


--
-- Name: index_events_on_library_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_events_on_library_id ON events USING btree (library_id);


--
-- Name: index_exemplifies_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_exemplifies_on_item_id ON exemplifies USING btree (item_id);


--
-- Name: index_exemplifies_on_manifestation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_exemplifies_on_manifestation_id ON exemplifies USING btree (manifestation_id);


--
-- Name: index_exemplifies_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_exemplifies_on_type ON exemplifies USING btree (type);


--
-- Name: index_expression_merges_on_expression_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_expression_merges_on_expression_id ON expression_merges USING btree (expression_id);


--
-- Name: index_expression_merges_on_expression_merge_list_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_expression_merges_on_expression_merge_list_id ON expression_merges USING btree (expression_merge_list_id);


--
-- Name: index_expressions_on_expression_form_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_expressions_on_expression_form_id ON expressions USING btree (expression_form_id);


--
-- Name: index_expressions_on_frequency_of_issue_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_expressions_on_frequency_of_issue_id ON expressions USING btree (frequency_of_issue_id);


--
-- Name: index_expressions_on_language_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_expressions_on_language_id ON expressions USING btree (language_id);


--
-- Name: index_expressions_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_expressions_on_parent_id ON expressions USING btree (parent_id);


--
-- Name: index_imported_files_on_db_file_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_imported_files_on_db_file_id ON imported_files USING btree (db_file_id);


--
-- Name: index_imported_files_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_imported_files_on_parent_id ON imported_files USING btree (parent_id);


--
-- Name: index_imported_files_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_imported_files_on_type ON imported_files USING btree (type);


--
-- Name: index_imported_files_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_imported_files_on_user_id ON imported_files USING btree (user_id);


--
-- Name: index_inter_library_loans_on_borrowing_library_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inter_library_loans_on_borrowing_library_id ON inter_library_loans USING btree (borrowing_library_id);


--
-- Name: index_inter_library_loans_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inter_library_loans_on_item_id ON inter_library_loans USING btree (item_id);


--
-- Name: index_item_has_use_restrictions_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_item_has_use_restrictions_on_item_id ON item_has_use_restrictions USING btree (item_id);


--
-- Name: index_item_has_use_restrictions_on_use_restriction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_item_has_use_restrictions_on_use_restriction_id ON item_has_use_restrictions USING btree (use_restriction_id);


--
-- Name: index_items_on_circulation_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_circulation_status_id ON items USING btree (circulation_status_id);


--
-- Name: index_items_on_item_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_item_identifier ON items USING btree (item_identifier);


--
-- Name: index_items_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_parent_id ON items USING btree (parent_id);


--
-- Name: index_items_on_shelf_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_shelf_id ON items USING btree (shelf_id);


--
-- Name: index_items_on_use_restriction_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_items_on_use_restriction_id ON items USING btree (use_restriction_id);


--
-- Name: index_languages_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_languages_on_name ON languages USING btree (name);


--
-- Name: index_libraries_on_library_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_libraries_on_library_group_id ON libraries USING btree (library_group_id);


--
-- Name: index_libraries_on_patron_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_libraries_on_patron_id ON libraries USING btree (patron_id);


--
-- Name: index_libraries_on_shortname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_libraries_on_shortname ON libraries USING btree (shortname);


--
-- Name: index_library_has_librarians_on_librarian_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_library_has_librarians_on_librarian_id ON library_has_librarians USING btree (librarian_id);


--
-- Name: index_library_has_librarians_on_library_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_library_has_librarians_on_library_id ON library_has_librarians USING btree (library_id);


--
-- Name: index_mail_on_message_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mail_on_message_id ON mail USING btree (message_id);


--
-- Name: index_mail_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mail_on_user_id ON mail USING btree (user_id);


--
-- Name: index_manifestations_on_manifestation_form_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_manifestations_on_manifestation_form_id ON manifestations USING btree (manifestation_form_id);


--
-- Name: index_manifestations_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_manifestations_on_parent_id ON manifestations USING btree (parent_id);


--
-- Name: index_message_templates_on_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_message_templates_on_status ON message_templates USING btree (status);


--
-- Name: index_messages_on_receiver_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_receiver_id ON messages USING btree (receiver_id);


--
-- Name: index_messages_on_sender_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_sender_id ON messages USING btree (sender_id);


--
-- Name: index_messages_recipients_on_message_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_recipients_on_message_id ON messages_recipients USING btree (message_id);


--
-- Name: index_messages_recipients_on_recipient_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_recipients_on_recipient_id ON messages_recipients USING btree (recipient_id);


--
-- Name: index_orders_on_bookstore_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orders_on_bookstore_id ON orders USING btree (bookstore_id);


--
-- Name: index_orders_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orders_on_item_id ON orders USING btree (item_id);


--
-- Name: index_orders_on_manifestation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orders_on_manifestation_id ON orders USING btree (manifestation_id);


--
-- Name: index_orders_on_purchase_request_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orders_on_purchase_request_id ON orders USING btree (purchase_request_id);


--
-- Name: index_orders_on_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orders_on_url ON orders USING btree (url);


--
-- Name: index_owns_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_owns_on_item_id ON owns USING btree (item_id);


--
-- Name: index_owns_on_patron_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_owns_on_patron_id ON owns USING btree (patron_id);


--
-- Name: index_owns_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_owns_on_type ON owns USING btree (type);


--
-- Name: index_patron_merges_on_patron_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_patron_merges_on_patron_id ON patron_merges USING btree (patron_id);


--
-- Name: index_patron_merges_on_patron_merge_list_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_patron_merges_on_patron_merge_list_id ON patron_merges USING btree (patron_merge_list_id);


--
-- Name: index_patrons_on_language_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_patrons_on_language_id ON patrons USING btree (language_id);


--
-- Name: index_patrons_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_patrons_on_parent_id ON patrons USING btree (parent_id);


--
-- Name: index_patrons_on_patron_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_patrons_on_patron_type_id ON patrons USING btree (patron_type_id);


--
-- Name: index_performs_on_expression_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_performs_on_expression_id ON performs USING btree (expression_id);


--
-- Name: index_performs_on_patron_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_performs_on_patron_id ON performs USING btree (patron_id);


--
-- Name: index_performs_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_performs_on_type ON performs USING btree (type);


--
-- Name: index_produces_on_manifestation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_produces_on_manifestation_id ON produces USING btree (manifestation_id);


--
-- Name: index_produces_on_patron_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_produces_on_patron_id ON produces USING btree (patron_id);


--
-- Name: index_produces_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_produces_on_type ON produces USING btree (type);


--
-- Name: index_purchase_requests_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_purchase_requests_on_user_id ON purchase_requests USING btree (user_id);


--
-- Name: index_questions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_questions_on_user_id ON questions USING btree (user_id);


--
-- Name: index_realizes_on_expression_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_realizes_on_expression_id ON realizes USING btree (expression_id);


--
-- Name: index_realizes_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_realizes_on_type ON realizes USING btree (type);


--
-- Name: index_realizes_on_work_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_realizes_on_work_id ON realizes USING btree (work_id);


--
-- Name: index_reservations_on_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reservations_on_item_id ON reservations USING btree (item_id);


--
-- Name: index_reservations_on_manifestation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reservations_on_manifestation_id ON reservations USING btree (manifestation_id);


--
-- Name: index_reservations_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reservations_on_user_id ON reservations USING btree (user_id);


--
-- Name: index_resource_has_subjects_on_subject_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resource_has_subjects_on_subject_id ON resource_has_subjects USING btree (subject_id);


--
-- Name: index_resource_has_subjects_on_subjectable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resource_has_subjects_on_subjectable_id ON resource_has_subjects USING btree (subjectable_id);


--
-- Name: index_resource_has_subjects_on_subjectable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resource_has_subjects_on_subjectable_type ON resource_has_subjects USING btree (subjectable_type);


--
-- Name: index_roles_users_on_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_users_on_role_id ON roles_users USING btree (role_id);


--
-- Name: index_roles_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_users_on_user_id ON roles_users USING btree (user_id);


--
-- Name: index_search_histories_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_search_histories_on_user_id ON search_histories USING btree (user_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_shelves_on_library_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_shelves_on_library_id ON shelves USING btree (library_id);


--
-- Name: index_shelves_on_web_shelf; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_shelves_on_web_shelf ON shelves USING btree (web_shelf);


--
-- Name: index_subject_broader_terms_on_broader_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subject_broader_terms_on_broader_term_id ON subject_broader_terms USING btree (broader_term_id);


--
-- Name: index_subject_broader_terms_on_narrower_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subject_broader_terms_on_narrower_term_id ON subject_broader_terms USING btree (narrower_term_id);


--
-- Name: index_subject_has_classifications_on_classification_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subject_has_classifications_on_classification_id ON subject_has_classifications USING btree (classification_id);


--
-- Name: index_subject_has_classifications_on_subject_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subject_has_classifications_on_subject_id ON subject_has_classifications USING btree (subject_id);


--
-- Name: index_subject_related_terms_on_related_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subject_related_terms_on_related_term_id ON subject_related_terms USING btree (related_term_id);


--
-- Name: index_subject_related_terms_on_subject_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subject_related_terms_on_subject_id ON subject_related_terms USING btree (subject_id);


--
-- Name: index_subjects_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subjects_on_parent_id ON subjects USING btree (parent_id);


--
-- Name: index_subjects_on_subject_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subjects_on_subject_type_id ON subjects USING btree (subject_type_id);


--
-- Name: index_subjects_on_term; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subjects_on_term ON subjects USING btree (term);


--
-- Name: index_subjects_on_use_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_subjects_on_use_term_id ON subjects USING btree (use_term_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type ON taggings USING btree (taggable_id, taggable_type);


--
-- Name: index_taggings_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_user_id ON taggings USING btree (user_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_users_on_access_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_access_role_id ON users USING btree (access_role_id);


--
-- Name: index_users_on_answer_rss_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_answer_rss_token ON users USING btree (answer_rss_token);


--
-- Name: index_users_on_checkout_icalendar_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_checkout_icalendar_token ON users USING btree (checkout_icalendar_token);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_login ON users USING btree (login);


--
-- Name: index_users_on_openid_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_openid_url ON users USING btree (openid_url);


--
-- Name: index_users_on_patron_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_patron_id ON users USING btree (patron_id);


--
-- Name: index_users_on_user_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_user_group_id ON users USING btree (user_group_id);


--
-- Name: index_work_merges_on_work_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_work_merges_on_work_id ON work_merges USING btree (work_id);


--
-- Name: index_work_merges_on_work_merge_list_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_work_merges_on_work_merge_list_id ON work_merges USING btree (work_merge_list_id);


--
-- Name: index_works_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_works_on_parent_id ON works USING btree (parent_id);


--
-- Name: index_works_on_work_form_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_works_on_work_form_id ON works USING btree (work_form_id);


--
-- Name: index_xml_response_files_on_manifestation_id_and_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_xml_response_files_on_manifestation_id_and_type ON xml_response_files USING btree (manifestation_id, type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('41');

INSERT INTO schema_migrations (version) VALUES ('47');

INSERT INTO schema_migrations (version) VALUES ('55');

INSERT INTO schema_migrations (version) VALUES ('56');

INSERT INTO schema_migrations (version) VALUES ('59');

INSERT INTO schema_migrations (version) VALUES ('65');

INSERT INTO schema_migrations (version) VALUES ('69');

INSERT INTO schema_migrations (version) VALUES ('73');

INSERT INTO schema_migrations (version) VALUES ('77');

INSERT INTO schema_migrations (version) VALUES ('80');

INSERT INTO schema_migrations (version) VALUES ('90');

INSERT INTO schema_migrations (version) VALUES ('98');

INSERT INTO schema_migrations (version) VALUES ('99');

INSERT INTO schema_migrations (version) VALUES ('101');

INSERT INTO schema_migrations (version) VALUES ('103');

INSERT INTO schema_migrations (version) VALUES ('108');

INSERT INTO schema_migrations (version) VALUES ('110');

INSERT INTO schema_migrations (version) VALUES ('112');

INSERT INTO schema_migrations (version) VALUES ('113');

INSERT INTO schema_migrations (version) VALUES ('114');

INSERT INTO schema_migrations (version) VALUES ('115');

INSERT INTO schema_migrations (version) VALUES ('117');

INSERT INTO schema_migrations (version) VALUES ('119');

INSERT INTO schema_migrations (version) VALUES ('120');

INSERT INTO schema_migrations (version) VALUES ('121');

INSERT INTO schema_migrations (version) VALUES ('123');

INSERT INTO schema_migrations (version) VALUES ('124');

INSERT INTO schema_migrations (version) VALUES ('125');

INSERT INTO schema_migrations (version) VALUES ('126');

INSERT INTO schema_migrations (version) VALUES ('127');

INSERT INTO schema_migrations (version) VALUES ('128');

INSERT INTO schema_migrations (version) VALUES ('129');

INSERT INTO schema_migrations (version) VALUES ('130');

INSERT INTO schema_migrations (version) VALUES ('131');

INSERT INTO schema_migrations (version) VALUES ('132');

INSERT INTO schema_migrations (version) VALUES ('133');

INSERT INTO schema_migrations (version) VALUES ('134');

INSERT INTO schema_migrations (version) VALUES ('135');

INSERT INTO schema_migrations (version) VALUES ('136');

INSERT INTO schema_migrations (version) VALUES ('137');

INSERT INTO schema_migrations (version) VALUES ('138');

INSERT INTO schema_migrations (version) VALUES ('20080927033109');

INSERT INTO schema_migrations (version) VALUES ('140');

INSERT INTO schema_migrations (version) VALUES ('141');

INSERT INTO schema_migrations (version) VALUES ('142');

INSERT INTO schema_migrations (version) VALUES ('143');

INSERT INTO schema_migrations (version) VALUES ('144');

INSERT INTO schema_migrations (version) VALUES ('146');

INSERT INTO schema_migrations (version) VALUES ('145');

INSERT INTO schema_migrations (version) VALUES ('148');

INSERT INTO schema_migrations (version) VALUES ('149');

INSERT INTO schema_migrations (version) VALUES ('154');

INSERT INTO schema_migrations (version) VALUES ('20080606052544');

INSERT INTO schema_migrations (version) VALUES ('20080627050228');

INSERT INTO schema_migrations (version) VALUES ('20080811160723');

INSERT INTO schema_migrations (version) VALUES ('20080812205738');

INSERT INTO schema_migrations (version) VALUES ('20080819181903');

INSERT INTO schema_migrations (version) VALUES ('20080830154109');

INSERT INTO schema_migrations (version) VALUES ('20080830172106');

INSERT INTO schema_migrations (version) VALUES ('20080905082936');

INSERT INTO schema_migrations (version) VALUES ('20080905084142');

INSERT INTO schema_migrations (version) VALUES ('20080905191442');

INSERT INTO schema_migrations (version) VALUES ('20080927101347');

INSERT INTO schema_migrations (version) VALUES ('20080927103707');

INSERT INTO schema_migrations (version) VALUES ('20080928054216');