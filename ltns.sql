--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.12
-- Dumped by pg_dump version 9.6.12

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: default_timings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.default_timings (
    id integer NOT NULL,
    timing character varying NOT NULL,
    CONSTRAINT default_timings_id_check CHECK ((id = 1))
);


ALTER TABLE public.default_timings OWNER TO postgres;

--
-- Name: default_timings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.default_timings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.default_timings_id_seq OWNER TO postgres;

--
-- Name: default_timings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.default_timings_id_seq OWNED BY public.default_timings.id;


--
-- Name: journey_runs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journey_runs (
    id bigint NOT NULL,
    journey_id bigint NOT NULL,
    run_id bigint NOT NULL,
    duration integer NOT NULL,
    duration_in_traffic integer NOT NULL,
    distance integer NOT NULL,
    overview_polyline jsonb NOT NULL
);


ALTER TABLE public.journey_runs OWNER TO postgres;

--
-- Name: journey_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.journey_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.journey_runs_id_seq OWNER TO postgres;

--
-- Name: journey_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.journey_runs_id_seq OWNED BY public.journey_runs.id;


--
-- Name: journeys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journeys (
    id bigint NOT NULL,
    ltn_id bigint NOT NULL,
    origin_lat numeric(11,8) NOT NULL,
    origin_lng numeric(11,8) NOT NULL,
    dest_lat numeric(11,8) NOT NULL,
    dest_lng numeric(11,8) NOT NULL,
    disabled boolean DEFAULT false NOT NULL
);


ALTER TABLE public.journeys OWNER TO postgres;

--
-- Name: journeys_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.journeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.journeys_id_seq OWNER TO postgres;

--
-- Name: journeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.journeys_id_seq OWNED BY public.journeys.id;


--
-- Name: ltns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ltns (
    id bigint NOT NULL,
    scheme_name character varying NOT NULL
);


ALTER TABLE public.ltns OWNER TO postgres;

--
-- Name: ltns_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ltns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ltns_id_seq OWNER TO postgres;

--
-- Name: ltns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ltns_id_seq OWNED BY public.ltns.id;


--
-- Name: runs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.runs (
    id bigint NOT NULL,
    ltn_id bigint NOT NULL,
    "time" timestamp with time zone NOT NULL
);


ALTER TABLE public.runs OWNER TO postgres;

--
-- Name: runs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.runs_id_seq OWNER TO postgres;

--
-- Name: runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.runs_id_seq OWNED BY public.runs.id;


--
-- Name: default_timings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.default_timings ALTER COLUMN id SET DEFAULT nextval('public.default_timings_id_seq'::regclass);


--
-- Name: journey_runs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journey_runs ALTER COLUMN id SET DEFAULT nextval('public.journey_runs_id_seq'::regclass);


--
-- Name: journeys id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journeys ALTER COLUMN id SET DEFAULT nextval('public.journeys_id_seq'::regclass);


--
-- Name: ltns id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ltns ALTER COLUMN id SET DEFAULT nextval('public.ltns_id_seq'::regclass);


--
-- Name: runs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.runs ALTER COLUMN id SET DEFAULT nextval('public.runs_id_seq'::regclass);


--
-- Name: default_timings default_timings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.default_timings
    ADD CONSTRAINT default_timings_pkey PRIMARY KEY (id);


--
-- Name: journey_runs journey_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journey_runs
    ADD CONSTRAINT journey_runs_pkey PRIMARY KEY (id);


--
-- Name: journeys journeys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journeys
    ADD CONSTRAINT journeys_pkey PRIMARY KEY (id);


--
-- Name: ltns ltns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ltns
    ADD CONSTRAINT ltns_pkey PRIMARY KEY (id);


--
-- Name: runs runs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT runs_pkey PRIMARY KEY (id);


--
-- Name: journey_runs_journey_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX journey_runs_journey_id ON public.journey_runs USING btree (journey_id);


--
-- Name: journey_runs_run_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX journey_runs_run_id ON public.journey_runs USING btree (run_id);


--
-- Name: journeys_ltn_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX journeys_ltn_id ON public.journeys USING btree (ltn_id) WHERE (NOT disabled);


--
-- Name: runs_ltn_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX runs_ltn_id ON public.runs USING btree (ltn_id);


--
-- Name: journey_runs journey_runs_journey_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journey_runs
    ADD CONSTRAINT journey_runs_journey_id FOREIGN KEY (journey_id) REFERENCES public.journeys(id);


--
-- Name: journey_runs journey_runs_run_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journey_runs
    ADD CONSTRAINT journey_runs_run_id FOREIGN KEY (run_id) REFERENCES public.runs(id);


--
-- Name: journeys journeys_ltn_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journeys
    ADD CONSTRAINT journeys_ltn_id FOREIGN KEY (ltn_id) REFERENCES public.ltns(id);


--
-- Name: runs runs_ltn_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.runs
    ADD CONSTRAINT runs_ltn_id FOREIGN KEY (ltn_id) REFERENCES public.ltns(id);


--
-- Name: TABLE default_timings; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.default_timings TO shared_role;


--
-- Name: COLUMN default_timings.timing; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(timing),UPDATE(timing) ON TABLE public.default_timings TO asker;


--
-- Name: SEQUENCE default_timings_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.default_timings_id_seq TO shared_role;


--
-- Name: TABLE journey_runs; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.journey_runs TO shared_role;


--
-- Name: COLUMN journey_runs.journey_id; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(journey_id) ON TABLE public.journey_runs TO r_program;


--
-- Name: COLUMN journey_runs.run_id; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(run_id) ON TABLE public.journey_runs TO r_program;


--
-- Name: COLUMN journey_runs.duration; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(duration) ON TABLE public.journey_runs TO r_program;


--
-- Name: COLUMN journey_runs.duration_in_traffic; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(duration_in_traffic) ON TABLE public.journey_runs TO r_program;


--
-- Name: COLUMN journey_runs.distance; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(distance) ON TABLE public.journey_runs TO r_program;


--
-- Name: COLUMN journey_runs.overview_polyline; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(overview_polyline) ON TABLE public.journey_runs TO r_program;


--
-- Name: SEQUENCE journey_runs_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.journey_runs_id_seq TO shared_role;


--
-- Name: TABLE journeys; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.journeys TO shared_role;


--
-- Name: COLUMN journeys.ltn_id; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(ltn_id) ON TABLE public.journeys TO asker;


--
-- Name: COLUMN journeys.origin_lat; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(origin_lat) ON TABLE public.journeys TO asker;


--
-- Name: COLUMN journeys.origin_lng; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(origin_lng) ON TABLE public.journeys TO asker;


--
-- Name: COLUMN journeys.dest_lat; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(dest_lat) ON TABLE public.journeys TO asker;


--
-- Name: COLUMN journeys.dest_lng; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(dest_lng) ON TABLE public.journeys TO asker;


--
-- Name: COLUMN journeys.disabled; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(disabled),UPDATE(disabled) ON TABLE public.journeys TO asker;


--
-- Name: SEQUENCE journeys_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.journeys_id_seq TO shared_role;


--
-- Name: TABLE ltns; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.ltns TO shared_role;


--
-- Name: COLUMN ltns.scheme_name; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(scheme_name),UPDATE(scheme_name) ON TABLE public.ltns TO asker;


--
-- Name: SEQUENCE ltns_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.ltns_id_seq TO shared_role;


--
-- Name: TABLE runs; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.runs TO shared_role;


--
-- Name: COLUMN runs.ltn_id; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT(ltn_id) ON TABLE public.runs TO r_program;


--
-- Name: COLUMN runs."time"; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT("time") ON TABLE public.runs TO r_program;


--
-- Name: SEQUENCE runs_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.runs_id_seq TO shared_role;


--
-- PostgreSQL database dump complete
--

