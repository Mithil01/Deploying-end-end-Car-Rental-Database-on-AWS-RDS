--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: availability_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.availability_enum AS ENUM (
    'Yes',
    'No'
);


ALTER TYPE public.availability_enum OWNER TO postgres;

--
-- Name: department_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.department_enum AS ENUM (
    'HR',
    'Finance',
    'IT',
    'Sales',
    'Marketing'
);


ALTER TYPE public.department_enum OWNER TO postgres;

--
-- Name: department_enum_updated; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.department_enum_updated AS ENUM (
    'HR',
    'Finance',
    'IT',
    'Sales',
    'Maintenance',
    'Security'
);


ALTER TYPE public.department_enum_updated OWNER TO postgres;

--
-- Name: fuel_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.fuel_type_enum AS ENUM (
    'Gasoline',
    'Diesel',
    'Electric',
    'Hybrid'
);


ALTER TYPE public.fuel_type_enum OWNER TO postgres;

--
-- Name: transmission_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.transmission_enum AS ENUM (
    'Automatic',
    'Manual',
    'Semi-Automatic'
);


ALTER TYPE public.transmission_enum OWNER TO postgres;

--
-- Name: copy_to_deleted_booking(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.copy_to_deleted_booking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Copy the row to deleted_booking_details
    INSERT INTO deleted_booking_details (booking_id, booking_date, pick_up_date, return_date, customer_id, 
        pick_up_location, return_location, emp_id, chauffeur_id, insurance_category, car_reg_no)
    SELECT OLD.booking_id, OLD.booking_date, OLD.pick_up_date, OLD.return_date, OLD.customer_id,
        OLD.pick_up_location, OLD.return_location, OLD.emp_id, OLD.chauffeur_id, OLD.insurance_category, OLD.car_reg_no;

    -- Delete the row from booking_details
    DELETE FROM booking_details WHERE booking_id = OLD.booking_id;

    RETURN OLD;
END;
$$;


ALTER FUNCTION public.copy_to_deleted_booking() OWNER TO postgres;

--
-- Name: fill_billing_details(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fill_billing_details() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare car_rent_cost float;
declare insurance_cost float;
declare chauffeur_cost float;
declare booking_cost float;
declare tax_amt float;
declare total_amount float;
declare discount_rate float;
declare car_rent_after_discount float;
BEGIN
    -- Calculate car_rent_cost
    SELECT (NEW.return_date - NEW.pick_up_date) * cc.cost_per_day
    INTO STRICT car_rent_cost
    FROM car_category cc
    WHERE cc.car_category_name = (SELECT car_category_name FROM car WHERE reg_no = NEW.car_reg_no);
	
	-- Calculate insurance cost
	SELECT (NEW.return_date - NEW.pick_up_date) * booking_insurance.cost_per_day
	into strict insurance_cost
	from booking_insurance
	where booking_insurance.insurance_category = new.insurance_category;
	
	--calculate chauffeur cost
	if new.chauffeur_id is NULL then
		chauffeur_cost:=0;
		
	else
		chauffeur_cost := (NEW.return_date - NEW.pick_up_date) * 75;
	end if;
	
	-- Check customer membership for discount
    SELECT mc.discount_rate
    INTO STRICT discount_rate
    FROM customer c
    LEFT JOIN membership_details md ON c.customer_id = md.customer_id
    LEFT JOIN Membership_category mc ON md.membership_type = mc.membership_type
    WHERE c.customer_id = NEW.customer_id;
	
	-- calculate car_rent_after_discount
	car_rent_after_discount := car_rent_cost - (discount_rate * 0.01 * car_rent_cost);
	
	-- Calculate booking cost
	booking_cost :=car_rent_after_discount + insurance_cost + chauffeur_cost;

    -- Calculate tax_amt
    tax_amt := 0.1 * booking_cost;

    -- Calculate total_amount
    total_amount := booking_cost + tax_amt;
	

    -- Insert data into the "billing_details" table
    INSERT INTO billing_details (booking_id, total_amount, booking_cost, tax_amt,car_rent_cost,chauffeur_cost,insurance_cost,car_rent_after_discount,discount_rate)
    VALUES (NEW.booking_id, total_amount, booking_cost, tax_amt,car_rent_cost,chauffeur_cost,insurance_cost,car_rent_after_discount,discount_rate);

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fill_billing_details() OWNER TO postgres;

--
-- Name: update_car_age(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_car_age() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.age := date_part('year', age(NEW.purchase_date))::INT;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_car_age() OWNER TO postgres;

--
-- Name: update_chauffeur_age(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_chauffeur_age() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.age := date_part('year', age(NEW.dateofbirth))::INT;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_chauffeur_age() OWNER TO postgres;

--
-- Name: update_customer_age(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_customer_age() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.age := date_part('year', age(NEW.dateofbirth))::INT;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_customer_age() OWNER TO postgres;

--
-- Name: update_employee_details_age(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_employee_details_age() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.age := date_part('year', age(NEW.dateofbirth))::INT;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_employee_details_age() OWNER TO postgres;

--
-- Name: validate_booking(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_booking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare car_branch_id int;
declare car_availability varchar;
declare employee_branch_id int;
declare employee_department varchar;
BEGIN
    -- Check if the pick-up date is today or in the future
    IF NEW.pick_up_date < current_date THEN
        RAISE EXCEPTION 'Pick-up date must be today or in the future.';
    END IF;
	
	-- check if return_date is before pick_up date
	if new.return_date<new.pick_up_date then
		raise exception 'Return date cannot be before pick-up date';
	end if;

    -- Check car availability
    SELECT branch_id, availability INTO STRICT car_branch_id, car_availability
    FROM car
    WHERE reg_no = NEW.car_reg_no;

    IF car_branch_id != NEW.pick_up_location THEN
        RAISE EXCEPTION 'Car branch and pick-up location do not match.';
    END IF;

    IF car_availability != 'Yes' THEN
        RAISE EXCEPTION 'Car is not available.';
    END IF;

    -- Check employee's branch
    SELECT branch_id,department INTO STRICT employee_branch_id,employee_department
    FROM employee_details
    WHERE emp_id = NEW.emp_id;

    IF employee_branch_id != NEW.pick_up_location THEN
        RAISE EXCEPTION 'Employee''s branch does not match pick-up location.';
    END IF;
	
	if employee_department != 'Sales' then
		raise exception 'Employee must be of a Sales Background';
	end if;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validate_booking() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: billing_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.billing_details (
    booking_id integer,
    total_amount double precision,
    booking_cost double precision,
    insurance_cost double precision,
    chauffeur_cost double precision,
    car_rent_cost double precision,
    discount_rate double precision,
    car_rent_after_discount double precision,
    tax_amt double precision
);


ALTER TABLE public.billing_details OWNER TO postgres;

--
-- Name: booking_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.booking_details (
    booking_id integer NOT NULL,
    booking_date date,
    pick_up_date date,
    return_date date,
    customer_id integer,
    pick_up_location integer,
    return_location integer,
    emp_id integer,
    chauffeur_id integer,
    insurance_category character varying,
    car_reg_no character varying
);


ALTER TABLE public.booking_details OWNER TO postgres;

--
-- Name: booking_details_booking_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.booking_details_booking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.booking_details_booking_id_seq OWNER TO postgres;

--
-- Name: booking_details_booking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.booking_details_booking_id_seq OWNED BY public.booking_details.booking_id;


--
-- Name: booking_insurance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.booking_insurance (
    insurance_category character varying NOT NULL,
    insurance_details character varying,
    cost_per_day double precision
);


ALTER TABLE public.booking_insurance OWNER TO postgres;

--
-- Name: branch_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.branch_details (
    branch_id integer NOT NULL,
    branch_name character varying,
    address character varying,
    zipcode character varying
);


ALTER TABLE public.branch_details OWNER TO postgres;

--
-- Name: branch_details_branch_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.branch_details_branch_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.branch_details_branch_id_seq OWNER TO postgres;

--
-- Name: branch_details_branch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.branch_details_branch_id_seq OWNED BY public.branch_details.branch_id;


--
-- Name: car; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.car (
    reg_no character varying NOT NULL,
    car_category_name character varying,
    insurance_policy character varying,
    model character varying,
    make character varying,
    fuel_type public.fuel_type_enum,
    transmission public.transmission_enum,
    color character varying,
    mileage double precision,
    branch_id integer,
    purchase_date date,
    age integer,
    availability public.availability_enum DEFAULT 'Yes'::public.availability_enum
);


ALTER TABLE public.car OWNER TO postgres;

--
-- Name: car_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.car_category (
    car_category_name character varying NOT NULL,
    seating_capacity integer,
    cost_per_day double precision,
    late_fee_per_hour double precision
);


ALTER TABLE public.car_category OWNER TO postgres;

--
-- Name: chauffeur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chauffeur (
    chauffeur_id integer NOT NULL,
    firstname character varying,
    lastname character varying,
    dateofbirth date,
    age integer,
    license_number character varying,
    branch_id integer
);


ALTER TABLE public.chauffeur OWNER TO postgres;

--
-- Name: chauffeur_chauffeur_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chauffeur_chauffeur_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.chauffeur_chauffeur_id_seq OWNER TO postgres;

--
-- Name: chauffeur_chauffeur_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chauffeur_chauffeur_id_seq OWNED BY public.chauffeur.chauffeur_id;


--
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    customer_id integer NOT NULL,
    firstname character varying,
    lastname character varying,
    email character varying,
    phone character varying,
    address character varying,
    city character varying,
    zipcode character varying,
    dateofbirth date,
    age integer,
    license_number character varying,
    emergency_contact_name character varying,
    emergency_contact_number character varying
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- Name: customer_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customer_customer_id_seq OWNER TO postgres;

--
-- Name: customer_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_customer_id_seq OWNED BY public.customer.customer_id;


--
-- Name: deleted_booking_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deleted_booking_details (
    del_id integer NOT NULL,
    booking_id integer,
    booking_date date,
    pick_up_date date,
    return_date date,
    customer_id integer,
    pick_up_location integer,
    return_location integer,
    emp_id integer,
    chauffeur_id integer,
    insurance_category character varying,
    car_reg_no character varying
);


ALTER TABLE public.deleted_booking_details OWNER TO postgres;

--
-- Name: deleted_booking_details_del_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.deleted_booking_details_del_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deleted_booking_details_del_id_seq OWNER TO postgres;

--
-- Name: deleted_booking_details_del_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.deleted_booking_details_del_id_seq OWNED BY public.deleted_booking_details.del_id;


--
-- Name: employee_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee_details (
    emp_id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    branch_id integer,
    dateofbirth date,
    age integer,
    department public.department_enum_updated
);


ALTER TABLE public.employee_details OWNER TO postgres;

--
-- Name: employee_details_emp_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_details_emp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_details_emp_id_seq OWNER TO postgres;

--
-- Name: employee_details_emp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_details_emp_id_seq OWNED BY public.employee_details.emp_id;


--
-- Name: membership_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.membership_category (
    membership_type character varying NOT NULL,
    discount_rate double precision
);


ALTER TABLE public.membership_category OWNER TO postgres;

--
-- Name: membership_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.membership_details (
    customer_id integer,
    join_date date,
    end_date date,
    membership_type character varying
);


ALTER TABLE public.membership_details OWNER TO postgres;

--
-- Name: booking_details booking_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_details ALTER COLUMN booking_id SET DEFAULT nextval('public.booking_details_booking_id_seq'::regclass);


--
-- Name: branch_details branch_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch_details ALTER COLUMN branch_id SET DEFAULT nextval('public.branch_details_branch_id_seq'::regclass);


--
-- Name: chauffeur chauffeur_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chauffeur ALTER COLUMN chauffeur_id SET DEFAULT nextval('public.chauffeur_chauffeur_id_seq'::regclass);


--
-- Name: customer customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer ALTER COLUMN customer_id SET DEFAULT nextval('public.customer_customer_id_seq'::regclass);


--
-- Name: deleted_booking_details del_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deleted_booking_details ALTER COLUMN del_id SET DEFAULT nextval('public.deleted_booking_details_del_id_seq'::regclass);


--
-- Name: employee_details emp_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_details ALTER COLUMN emp_id SET DEFAULT nextval('public.employee_details_emp_id_seq'::regclass);


--
-- Name: booking_details booking_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_pkey PRIMARY KEY (booking_id);


--
-- Name: booking_insurance booking_insurance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_insurance
    ADD CONSTRAINT booking_insurance_pkey PRIMARY KEY (insurance_category);


--
-- Name: branch_details branch_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch_details
    ADD CONSTRAINT branch_details_pkey PRIMARY KEY (branch_id);


--
-- Name: car_category car_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car_category
    ADD CONSTRAINT car_category_pkey PRIMARY KEY (car_category_name);


--
-- Name: car car_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_pkey PRIMARY KEY (reg_no);


--
-- Name: chauffeur chauffeur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chauffeur
    ADD CONSTRAINT chauffeur_pkey PRIMARY KEY (chauffeur_id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- Name: deleted_booking_details deleted_booking_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deleted_booking_details
    ADD CONSTRAINT deleted_booking_details_pkey PRIMARY KEY (del_id);


--
-- Name: employee_details employee_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_details
    ADD CONSTRAINT employee_details_pkey PRIMARY KEY (emp_id);


--
-- Name: membership_category membership_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership_category
    ADD CONSTRAINT membership_category_pkey PRIMARY KEY (membership_type);


--
-- Name: booking_details copy_to_deleted_booking_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER copy_to_deleted_booking_trigger AFTER DELETE ON public.booking_details FOR EACH ROW EXECUTE FUNCTION public.copy_to_deleted_booking();


--
-- Name: booking_details fill_billing_details_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER fill_billing_details_trigger AFTER INSERT ON public.booking_details FOR EACH ROW EXECUTE FUNCTION public.fill_billing_details();


--
-- Name: car update_car_age_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_car_age_trigger BEFORE INSERT OR UPDATE ON public.car FOR EACH ROW EXECUTE FUNCTION public.update_car_age();


--
-- Name: chauffeur update_chauffeur_age_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_chauffeur_age_trigger BEFORE INSERT OR UPDATE ON public.chauffeur FOR EACH ROW EXECUTE FUNCTION public.update_chauffeur_age();


--
-- Name: customer update_customer_age_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_customer_age_trigger BEFORE INSERT OR UPDATE ON public.customer FOR EACH ROW EXECUTE FUNCTION public.update_customer_age();


--
-- Name: employee_details update_employee_details_age_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_employee_details_age_trigger BEFORE INSERT OR UPDATE ON public.employee_details FOR EACH ROW EXECUTE FUNCTION public.update_employee_details_age();


--
-- Name: booking_details validate_booking_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER validate_booking_trigger BEFORE INSERT ON public.booking_details FOR EACH ROW EXECUTE FUNCTION public.validate_booking();


--
-- Name: billing_details billing_details_booking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.billing_details
    ADD CONSTRAINT billing_details_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.booking_details(booking_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: booking_details booking_details_car_reg_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_car_reg_no_fkey FOREIGN KEY (car_reg_no) REFERENCES public.car(reg_no) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: booking_details booking_details_chauffeur_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_chauffeur_id_fkey FOREIGN KEY (chauffeur_id) REFERENCES public.chauffeur(chauffeur_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: booking_details booking_details_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: booking_details booking_details_emp_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_emp_id_fkey FOREIGN KEY (emp_id) REFERENCES public.employee_details(emp_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: booking_details booking_details_insurance_category_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_insurance_category_fkey FOREIGN KEY (insurance_category) REFERENCES public.booking_insurance(insurance_category) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: booking_details booking_details_pick_up_location_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_pick_up_location_fkey FOREIGN KEY (pick_up_location) REFERENCES public.branch_details(branch_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: booking_details booking_details_return_location_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_return_location_fkey FOREIGN KEY (return_location) REFERENCES public.branch_details(branch_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: car car_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch_details(branch_id);


--
-- Name: car car_car_category_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_car_category_name_fkey FOREIGN KEY (car_category_name) REFERENCES public.car_category(car_category_name);


--
-- Name: chauffeur chauffeur_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chauffeur
    ADD CONSTRAINT chauffeur_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch_details(branch_id);


--
-- Name: employee_details employee_details_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_details
    ADD CONSTRAINT employee_details_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch_details(branch_id);


--
-- Name: membership_details membership_details_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership_details
    ADD CONSTRAINT membership_details_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);


--
-- Name: membership_details membership_details_membership_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.membership_details
    ADD CONSTRAINT membership_details_membership_type_fkey FOREIGN KEY (membership_type) REFERENCES public.membership_category(membership_type);


--
-- PostgreSQL database dump complete
--

