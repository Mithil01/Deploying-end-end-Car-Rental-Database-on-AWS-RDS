PGDMP          3                {            car_rental_system    15.4    15.4 `    ~           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16736    car_rental_system    DATABASE     �   CREATE DATABASE car_rental_system WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
 !   DROP DATABASE car_rental_system;
                postgres    false            �           0    0    DATABASE car_rental_system    COMMENT     Q   COMMENT ON DATABASE car_rental_system IS 'project work with vignesh and mithil';
                   postgres    false    3457            x           1247    17251    availability_enum    TYPE     F   CREATE TYPE public.availability_enum AS ENUM (
    'Yes',
    'No'
);
 $   DROP TYPE public.availability_enum;
       public          postgres    false            l           1247    16977    department_enum    TYPE     p   CREATE TYPE public.department_enum AS ENUM (
    'HR',
    'Finance',
    'IT',
    'Sales',
    'Marketing'
);
 "   DROP TYPE public.department_enum;
       public          postgres    false            �           1247    17370    department_enum_updated    TYPE     �   CREATE TYPE public.department_enum_updated AS ENUM (
    'HR',
    'Finance',
    'IT',
    'Sales',
    'Maintenance',
    'Security'
);
 *   DROP TYPE public.department_enum_updated;
       public          postgres    false            o           1247    17038    fuel_type_enum    TYPE     j   CREATE TYPE public.fuel_type_enum AS ENUM (
    'Gasoline',
    'Diesel',
    'Electric',
    'Hybrid'
);
 !   DROP TYPE public.fuel_type_enum;
       public          postgres    false            r           1247    17048    transmission_enum    TYPE     f   CREATE TYPE public.transmission_enum AS ENUM (
    'Automatic',
    'Manual',
    'Semi-Automatic'
);
 $   DROP TYPE public.transmission_enum;
       public          postgres    false            �            1255    17896    copy_to_deleted_booking()    FUNCTION     �  CREATE FUNCTION public.copy_to_deleted_booking() RETURNS trigger
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
 0   DROP FUNCTION public.copy_to_deleted_booking();
       public          postgres    false            �            1255    17872    fill_billing_details()    FUNCTION     	  CREATE FUNCTION public.fill_billing_details() RETURNS trigger
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
 -   DROP FUNCTION public.fill_billing_details();
       public          postgres    false            �            1255    17106    update_car_age()    FUNCTION     �   CREATE FUNCTION public.update_car_age() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.age := date_part('year', age(NEW.purchase_date))::INT;
    RETURN NEW;
END;
$$;
 '   DROP FUNCTION public.update_car_age();
       public          postgres    false            �            1255    16958    update_chauffeur_age()    FUNCTION     �   CREATE FUNCTION public.update_chauffeur_age() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.age := date_part('year', age(NEW.dateofbirth))::INT;
    RETURN NEW;
END;
$$;
 -   DROP FUNCTION public.update_chauffeur_age();
       public          postgres    false            �            1255    16920    update_customer_age()    FUNCTION     �   CREATE FUNCTION public.update_customer_age() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.age := date_part('year', age(NEW.dateofbirth))::INT;
    RETURN NEW;
END;
$$;
 ,   DROP FUNCTION public.update_customer_age();
       public          postgres    false            �            1255    16996    update_employee_details_age()    FUNCTION     �   CREATE FUNCTION public.update_employee_details_age() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.age := date_part('year', age(NEW.dateofbirth))::INT;
    RETURN NEW;
END;
$$;
 4   DROP FUNCTION public.update_employee_details_age();
       public          postgres    false            �            1255    17406    validate_booking()    FUNCTION     �  CREATE FUNCTION public.validate_booking() RETURNS trigger
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
 )   DROP FUNCTION public.validate_booking();
       public          postgres    false            �            1259    17933    billing_details    TABLE     d  CREATE TABLE public.billing_details (
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
 #   DROP TABLE public.billing_details;
       public         heap    postgres    false            �            1259    17821    booking_details    TABLE     [  CREATE TABLE public.booking_details (
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
 #   DROP TABLE public.booking_details;
       public         heap    postgres    false            �            1259    17820    booking_details_booking_id_seq    SEQUENCE     �   CREATE SEQUENCE public.booking_details_booking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.booking_details_booking_id_seq;
       public          postgres    false    228            �           0    0    booking_details_booking_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.booking_details_booking_id_seq OWNED BY public.booking_details.booking_id;
          public          postgres    false    227            �            1259    16789    booking_insurance    TABLE     �   CREATE TABLE public.booking_insurance (
    insurance_category character varying NOT NULL,
    insurance_details character varying,
    cost_per_day double precision
);
 %   DROP TABLE public.booking_insurance;
       public         heap    postgres    false            �            1259    16827    branch_details    TABLE     �   CREATE TABLE public.branch_details (
    branch_id integer NOT NULL,
    branch_name character varying,
    address character varying,
    zipcode character varying
);
 "   DROP TABLE public.branch_details;
       public         heap    postgres    false            �            1259    16826    branch_details_branch_id_seq    SEQUENCE     �   CREATE SEQUENCE public.branch_details_branch_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.branch_details_branch_id_seq;
       public          postgres    false    218            �           0    0    branch_details_branch_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.branch_details_branch_id_seq OWNED BY public.branch_details.branch_id;
          public          postgres    false    217            �            1259    17108    car    TABLE     �  CREATE TABLE public.car (
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
    DROP TABLE public.car;
       public         heap    postgres    false    888    879    882    888            �            1259    16796    car_category    TABLE     �   CREATE TABLE public.car_category (
    car_category_name character varying NOT NULL,
    seating_capacity integer,
    cost_per_day double precision,
    late_fee_per_hour double precision
);
     DROP TABLE public.car_category;
       public         heap    postgres    false            �            1259    16961 	   chauffeur    TABLE     �   CREATE TABLE public.chauffeur (
    chauffeur_id integer NOT NULL,
    firstname character varying,
    lastname character varying,
    dateofbirth date,
    age integer,
    license_number character varying,
    branch_id integer
);
    DROP TABLE public.chauffeur;
       public         heap    postgres    false            �            1259    16960    chauffeur_chauffeur_id_seq    SEQUENCE     �   CREATE SEQUENCE public.chauffeur_chauffeur_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.chauffeur_chauffeur_id_seq;
       public          postgres    false    220            �           0    0    chauffeur_chauffeur_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.chauffeur_chauffeur_id_seq OWNED BY public.chauffeur.chauffeur_id;
          public          postgres    false    219            �            1259    17292    customer    TABLE     �  CREATE TABLE public.customer (
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
    DROP TABLE public.customer;
       public         heap    postgres    false            �            1259    17291    customer_customer_id_seq    SEQUENCE     �   CREATE SEQUENCE public.customer_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.customer_customer_id_seq;
       public          postgres    false    225            �           0    0    customer_customer_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.customer_customer_id_seq OWNED BY public.customer.customer_id;
          public          postgres    false    224            �            1259    17883    deleted_booking_details    TABLE     w  CREATE TABLE public.deleted_booking_details (
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
 +   DROP TABLE public.deleted_booking_details;
       public         heap    postgres    false            �            1259    17882 "   deleted_booking_details_del_id_seq    SEQUENCE     �   CREATE SEQUENCE public.deleted_booking_details_del_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.deleted_booking_details_del_id_seq;
       public          postgres    false    230            �           0    0 "   deleted_booking_details_del_id_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE public.deleted_booking_details_del_id_seq OWNED BY public.deleted_booking_details.del_id;
          public          postgres    false    229            �            1259    17272    employee_details    TABLE     �   CREATE TABLE public.employee_details (
    emp_id integer NOT NULL,
    first_name character varying,
    last_name character varying,
    branch_id integer,
    dateofbirth date,
    age integer,
    department public.department_enum_updated
);
 $   DROP TABLE public.employee_details;
       public         heap    postgres    false    900            �            1259    17271    employee_details_emp_id_seq    SEQUENCE     �   CREATE SEQUENCE public.employee_details_emp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.employee_details_emp_id_seq;
       public          postgres    false    223            �           0    0    employee_details_emp_id_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public.employee_details_emp_id_seq OWNED BY public.employee_details.emp_id;
          public          postgres    false    222            �            1259    16768    membership_category    TABLE     �   CREATE TABLE public.membership_category (
    membership_type character varying NOT NULL,
    discount_rate double precision
);
 '   DROP TABLE public.membership_category;
       public         heap    postgres    false            �            1259    17301    membership_details    TABLE     �   CREATE TABLE public.membership_details (
    customer_id integer,
    join_date date,
    end_date date,
    membership_type character varying
);
 &   DROP TABLE public.membership_details;
       public         heap    postgres    false            �           2604    17824    booking_details booking_id    DEFAULT     �   ALTER TABLE ONLY public.booking_details ALTER COLUMN booking_id SET DEFAULT nextval('public.booking_details_booking_id_seq'::regclass);
 I   ALTER TABLE public.booking_details ALTER COLUMN booking_id DROP DEFAULT;
       public          postgres    false    227    228    228            �           2604    16830    branch_details branch_id    DEFAULT     �   ALTER TABLE ONLY public.branch_details ALTER COLUMN branch_id SET DEFAULT nextval('public.branch_details_branch_id_seq'::regclass);
 G   ALTER TABLE public.branch_details ALTER COLUMN branch_id DROP DEFAULT;
       public          postgres    false    218    217    218            �           2604    16964    chauffeur chauffeur_id    DEFAULT     �   ALTER TABLE ONLY public.chauffeur ALTER COLUMN chauffeur_id SET DEFAULT nextval('public.chauffeur_chauffeur_id_seq'::regclass);
 E   ALTER TABLE public.chauffeur ALTER COLUMN chauffeur_id DROP DEFAULT;
       public          postgres    false    219    220    220            �           2604    17295    customer customer_id    DEFAULT     |   ALTER TABLE ONLY public.customer ALTER COLUMN customer_id SET DEFAULT nextval('public.customer_customer_id_seq'::regclass);
 C   ALTER TABLE public.customer ALTER COLUMN customer_id DROP DEFAULT;
       public          postgres    false    225    224    225            �           2604    17886    deleted_booking_details del_id    DEFAULT     �   ALTER TABLE ONLY public.deleted_booking_details ALTER COLUMN del_id SET DEFAULT nextval('public.deleted_booking_details_del_id_seq'::regclass);
 M   ALTER TABLE public.deleted_booking_details ALTER COLUMN del_id DROP DEFAULT;
       public          postgres    false    230    229    230            �           2604    17275    employee_details emp_id    DEFAULT     �   ALTER TABLE ONLY public.employee_details ALTER COLUMN emp_id SET DEFAULT nextval('public.employee_details_emp_id_seq'::regclass);
 F   ALTER TABLE public.employee_details ALTER COLUMN emp_id DROP DEFAULT;
       public          postgres    false    223    222    223            {          0    17933    billing_details 
   TABLE DATA           �   COPY public.billing_details (booking_id, total_amount, booking_cost, insurance_cost, chauffeur_cost, car_rent_cost, discount_rate, car_rent_after_discount, tax_amt) FROM stdin;
    public          postgres    false    231   ��       x          0    17821    booking_details 
   TABLE DATA           �   COPY public.booking_details (booking_id, booking_date, pick_up_date, return_date, customer_id, pick_up_location, return_location, emp_id, chauffeur_id, insurance_category, car_reg_no) FROM stdin;
    public          postgres    false    228   �,      k          0    16789    booking_insurance 
   TABLE DATA           `   COPY public.booking_insurance (insurance_category, insurance_details, cost_per_day) FROM stdin;
    public          postgres    false    215   '�      n          0    16827    branch_details 
   TABLE DATA           R   COPY public.branch_details (branch_id, branch_name, address, zipcode) FROM stdin;
    public          postgres    false    218   ��      q          0    17108    car 
   TABLE DATA           �   COPY public.car (reg_no, car_category_name, insurance_policy, model, make, fuel_type, transmission, color, mileage, branch_id, purchase_date, age, availability) FROM stdin;
    public          postgres    false    221   �      l          0    16796    car_category 
   TABLE DATA           l   COPY public.car_category (car_category_name, seating_capacity, cost_per_day, late_fee_per_hour) FROM stdin;
    public          postgres    false    216   �      p          0    16961 	   chauffeur 
   TABLE DATA           s   COPY public.chauffeur (chauffeur_id, firstname, lastname, dateofbirth, age, license_number, branch_id) FROM stdin;
    public          postgres    false    220   n      u          0    17292    customer 
   TABLE DATA           �   COPY public.customer (customer_id, firstname, lastname, email, phone, address, city, zipcode, dateofbirth, age, license_number, emergency_contact_name, emergency_contact_number) FROM stdin;
    public          postgres    false    225   P      z          0    17883    deleted_booking_details 
   TABLE DATA           �   COPY public.deleted_booking_details (del_id, booking_id, booking_date, pick_up_date, return_date, customer_id, pick_up_location, return_location, emp_id, chauffeur_id, insurance_category, car_reg_no) FROM stdin;
    public          postgres    false    230   �M      s          0    17272    employee_details 
   TABLE DATA           r   COPY public.employee_details (emp_id, first_name, last_name, branch_id, dateofbirth, age, department) FROM stdin;
    public          postgres    false    223   �P      j          0    16768    membership_category 
   TABLE DATA           M   COPY public.membership_category (membership_type, discount_rate) FROM stdin;
    public          postgres    false    214   �^      v          0    17301    membership_details 
   TABLE DATA           _   COPY public.membership_details (customer_id, join_date, end_date, membership_type) FROM stdin;
    public          postgres    false    226   N_      �           0    0    booking_details_booking_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.booking_details_booking_id_seq', 2981, true);
          public          postgres    false    227            �           0    0    branch_details_branch_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.branch_details_branch_id_seq', 50, true);
          public          postgres    false    217            �           0    0    chauffeur_chauffeur_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public.chauffeur_chauffeur_id_seq', 120, true);
          public          postgres    false    219            �           0    0    customer_customer_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.customer_customer_id_seq', 300, true);
          public          postgres    false    224            �           0    0 "   deleted_booking_details_del_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.deleted_booking_details_del_id_seq', 46, true);
          public          postgres    false    229            �           0    0    employee_details_emp_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.employee_details_emp_id_seq', 211, true);
          public          postgres    false    222            �           2606    17828 $   booking_details booking_details_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_pkey PRIMARY KEY (booking_id);
 N   ALTER TABLE ONLY public.booking_details DROP CONSTRAINT booking_details_pkey;
       public            postgres    false    228            �           2606    16795 (   booking_insurance booking_insurance_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.booking_insurance
    ADD CONSTRAINT booking_insurance_pkey PRIMARY KEY (insurance_category);
 R   ALTER TABLE ONLY public.booking_insurance DROP CONSTRAINT booking_insurance_pkey;
       public            postgres    false    215            �           2606    16834 "   branch_details branch_details_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.branch_details
    ADD CONSTRAINT branch_details_pkey PRIMARY KEY (branch_id);
 L   ALTER TABLE ONLY public.branch_details DROP CONSTRAINT branch_details_pkey;
       public            postgres    false    218            �           2606    16802    car_category car_category_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.car_category
    ADD CONSTRAINT car_category_pkey PRIMARY KEY (car_category_name);
 H   ALTER TABLE ONLY public.car_category DROP CONSTRAINT car_category_pkey;
       public            postgres    false    216            �           2606    17114    car car_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_pkey PRIMARY KEY (reg_no);
 6   ALTER TABLE ONLY public.car DROP CONSTRAINT car_pkey;
       public            postgres    false    221            �           2606    16968    chauffeur chauffeur_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.chauffeur
    ADD CONSTRAINT chauffeur_pkey PRIMARY KEY (chauffeur_id);
 B   ALTER TABLE ONLY public.chauffeur DROP CONSTRAINT chauffeur_pkey;
       public            postgres    false    220            �           2606    17299    customer customer_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);
 @   ALTER TABLE ONLY public.customer DROP CONSTRAINT customer_pkey;
       public            postgres    false    225            �           2606    17890 4   deleted_booking_details deleted_booking_details_pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.deleted_booking_details
    ADD CONSTRAINT deleted_booking_details_pkey PRIMARY KEY (del_id);
 ^   ALTER TABLE ONLY public.deleted_booking_details DROP CONSTRAINT deleted_booking_details_pkey;
       public            postgres    false    230            �           2606    17279 &   employee_details employee_details_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.employee_details
    ADD CONSTRAINT employee_details_pkey PRIMARY KEY (emp_id);
 P   ALTER TABLE ONLY public.employee_details DROP CONSTRAINT employee_details_pkey;
       public            postgres    false    223            �           2606    16774 ,   membership_category membership_category_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY public.membership_category
    ADD CONSTRAINT membership_category_pkey PRIMARY KEY (membership_type);
 V   ALTER TABLE ONLY public.membership_category DROP CONSTRAINT membership_category_pkey;
       public            postgres    false    214            �           2620    17897 /   booking_details copy_to_deleted_booking_trigger    TRIGGER     �   CREATE TRIGGER copy_to_deleted_booking_trigger AFTER DELETE ON public.booking_details FOR EACH ROW EXECUTE FUNCTION public.copy_to_deleted_booking();
 H   DROP TRIGGER copy_to_deleted_booking_trigger ON public.booking_details;
       public          postgres    false    228    236            �           2620    17875 ,   booking_details fill_billing_details_trigger    TRIGGER     �   CREATE TRIGGER fill_billing_details_trigger AFTER INSERT ON public.booking_details FOR EACH ROW EXECUTE FUNCTION public.fill_billing_details();
 E   DROP TRIGGER fill_billing_details_trigger ON public.booking_details;
       public          postgres    false    228    249            �           2620    17125    car update_car_age_trigger    TRIGGER     �   CREATE TRIGGER update_car_age_trigger BEFORE INSERT OR UPDATE ON public.car FOR EACH ROW EXECUTE FUNCTION public.update_car_age();
 3   DROP TRIGGER update_car_age_trigger ON public.car;
       public          postgres    false    221    234            �           2620    16974 &   chauffeur update_chauffeur_age_trigger    TRIGGER     �   CREATE TRIGGER update_chauffeur_age_trigger BEFORE INSERT OR UPDATE ON public.chauffeur FOR EACH ROW EXECUTE FUNCTION public.update_chauffeur_age();
 ?   DROP TRIGGER update_chauffeur_age_trigger ON public.chauffeur;
       public          postgres    false    220    233            �           2620    17300 $   customer update_customer_age_trigger    TRIGGER     �   CREATE TRIGGER update_customer_age_trigger BEFORE INSERT OR UPDATE ON public.customer FOR EACH ROW EXECUTE FUNCTION public.update_customer_age();
 =   DROP TRIGGER update_customer_age_trigger ON public.customer;
       public          postgres    false    232    225            �           2620    17285 4   employee_details update_employee_details_age_trigger    TRIGGER     �   CREATE TRIGGER update_employee_details_age_trigger BEFORE INSERT OR UPDATE ON public.employee_details FOR EACH ROW EXECUTE FUNCTION public.update_employee_details_age();
 M   DROP TRIGGER update_employee_details_age_trigger ON public.employee_details;
       public          postgres    false    235    223            �           2620    17876 (   booking_details validate_booking_trigger    TRIGGER     �   CREATE TRIGGER validate_booking_trigger BEFORE INSERT ON public.booking_details FOR EACH ROW EXECUTE FUNCTION public.validate_booking();
 A   DROP TRIGGER validate_booking_trigger ON public.booking_details;
       public          postgres    false    228    248            �           2606    17941 /   billing_details billing_details_booking_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.billing_details
    ADD CONSTRAINT billing_details_booking_id_fkey FOREIGN KEY (booking_id) REFERENCES public.booking_details(booking_id) ON UPDATE CASCADE ON DELETE CASCADE;
 Y   ALTER TABLE ONLY public.billing_details DROP CONSTRAINT billing_details_booking_id_fkey;
       public          postgres    false    231    3268    228            �           2606    17877 /   booking_details booking_details_car_reg_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_car_reg_no_fkey FOREIGN KEY (car_reg_no) REFERENCES public.car(reg_no) ON UPDATE CASCADE ON DELETE CASCADE;
 Y   ALTER TABLE ONLY public.booking_details DROP CONSTRAINT booking_details_car_reg_no_fkey;
       public          postgres    false    228    3262    221            �           2606    17898 1   booking_details booking_details_chauffeur_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_chauffeur_id_fkey FOREIGN KEY (chauffeur_id) REFERENCES public.chauffeur(chauffeur_id) ON UPDATE CASCADE ON DELETE CASCADE;
 [   ALTER TABLE ONLY public.booking_details DROP CONSTRAINT booking_details_chauffeur_id_fkey;
       public          postgres    false    3260    220    228            �           2606    17928 0   booking_details booking_details_customer_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.booking_details DROP CONSTRAINT booking_details_customer_id_fkey;
       public          postgres    false    228    225    3266            �           2606    17908 +   booking_details booking_details_emp_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_emp_id_fkey FOREIGN KEY (emp_id) REFERENCES public.employee_details(emp_id) ON UPDATE CASCADE ON DELETE SET NULL;
 U   ALTER TABLE ONLY public.booking_details DROP CONSTRAINT booking_details_emp_id_fkey;
       public          postgres    false    228    223    3264            �           2606    17923 7   booking_details booking_details_insurance_category_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_insurance_category_fkey FOREIGN KEY (insurance_category) REFERENCES public.booking_insurance(insurance_category) ON UPDATE CASCADE ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.booking_details DROP CONSTRAINT booking_details_insurance_category_fkey;
       public          postgres    false    228    3254    215            �           2606    17918 5   booking_details booking_details_pick_up_location_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_pick_up_location_fkey FOREIGN KEY (pick_up_location) REFERENCES public.branch_details(branch_id) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.booking_details DROP CONSTRAINT booking_details_pick_up_location_fkey;
       public          postgres    false    228    218    3258            �           2606    17913 4   booking_details booking_details_return_location_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.booking_details
    ADD CONSTRAINT booking_details_return_location_fkey FOREIGN KEY (return_location) REFERENCES public.branch_details(branch_id) ON UPDATE CASCADE ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.booking_details DROP CONSTRAINT booking_details_return_location_fkey;
       public          postgres    false    3258    228    218            �           2606    17120    car car_branch_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch_details(branch_id);
 @   ALTER TABLE ONLY public.car DROP CONSTRAINT car_branch_id_fkey;
       public          postgres    false    3258    221    218            �           2606    17115    car car_car_category_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.car
    ADD CONSTRAINT car_car_category_name_fkey FOREIGN KEY (car_category_name) REFERENCES public.car_category(car_category_name);
 H   ALTER TABLE ONLY public.car DROP CONSTRAINT car_car_category_name_fkey;
       public          postgres    false    216    3256    221            �           2606    16969 "   chauffeur chauffeur_branch_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.chauffeur
    ADD CONSTRAINT chauffeur_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch_details(branch_id);
 L   ALTER TABLE ONLY public.chauffeur DROP CONSTRAINT chauffeur_branch_id_fkey;
       public          postgres    false    218    220    3258            �           2606    17280 0   employee_details employee_details_branch_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.employee_details
    ADD CONSTRAINT employee_details_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch_details(branch_id);
 Z   ALTER TABLE ONLY public.employee_details DROP CONSTRAINT employee_details_branch_id_fkey;
       public          postgres    false    223    3258    218            �           2606    17306 6   membership_details membership_details_customer_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.membership_details
    ADD CONSTRAINT membership_details_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id);
 `   ALTER TABLE ONLY public.membership_details DROP CONSTRAINT membership_details_customer_id_fkey;
       public          postgres    false    226    225    3266            �           2606    17311 :   membership_details membership_details_membership_type_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.membership_details
    ADD CONSTRAINT membership_details_membership_type_fkey FOREIGN KEY (membership_type) REFERENCES public.membership_category(membership_type);
 d   ALTER TABLE ONLY public.membership_details DROP CONSTRAINT membership_details_membership_type_fkey;
       public          postgres    false    226    3252    214            {      x��]�v�Ln�m?�O����XP�&	4=�I��$��uK��n,�B�կ\�O�_9����O��5|��������O?���5d�L�����e]h��������O�5����|�|ʐ/J~~Ð�����\����)�����I��~��׊��
|���ȿ|��UR��_y䯔�%�#3�]~T��S���k��[�#>7v���T�/?���=~�ڿ����"�[���w�_�{��9��h~�W�'�nկ$�������ɟ~�Y+���Ƕ,��7|���B_�|�w/_=�"��Zs������r�ה7M��Q��b^����^G���=���Wȕɥ��i/�4�\���ұ[�O�B|�<�����k?�n�����J1͟ W7s���K�-����<ف��T�I�kF~�����������d��,?�[�KQ��}���_���:�z�)�En���{Dو�K�&�ŷ�y��?����=��fy�5�y����ڰ��Ӫ|~�_MvBğڐ��_M~����>�[n&����EV�I]��\v*�G��_�{qӿ����8s]C��3��:���1M~m���俕��̇��6~Z�?��s��T�
���S�; �Y��E>�)_\~.~4���t?7}�U�W�,Y;��bU�~�vx�|�A����o���e��h/L��{!����������g8K��',�~�UOV��,��/�����R>-ؑ�<�_d7~O�s1K�&ߟyK����.����Y_�dy����ܕ�cw=��&X���j�C6��z�qb�yN�Fw��N��dGwyG��Z{�?��,��pjf�j��%Nˀ���GǑ�����ã��	sESB�ݬB�*7�'��?�~��(�5��҇"_\���B�ʓ�#���؇��篙��FY)�9�l�	�/�J���|��YG�u��f��>yY,�U���<�ssX��T_匆���刭+�%��m��6�N���[΀�9:�����_���aʣ�tL5�+�MƏs���9}GFr�֦V<�/�U#b����=bU�-�%#J��|V�&���ɱ�o/p^������+��&y��5q�s�K��,�y^��R�Ӑ�?�.��Vy���g����(��l����jr�'��W�Ƨ�nO9j���1����QN�l2�&�Z_c\����5"89��~��0��Kv
�zĦ[O_�c��i�~�|:�А��M�y"C��p Q\�q�l�qW%oXܸ/jÉ-�+{��ȷ�,4����b��슋�v��81�&F,z��L8��;t8�9q�e���d���h�i��񧗏��w�L�k�ϐ�������y�ܽ��e��܁�����>�=�u[�S�ɛ�C��{A� ���H�e�&�_�'��z"B���l�~3��e��b�]��;2WX[I�b8�#r��g�����j�E�ܸ����͐�I�7#��͗���F������tdn�H��o�W��x���a�g6Q��-�Oj��$�o�YF���o&.�<0���b���Yo8MG�o�����.
ۢN�9ؘ��Vk(���tb����k8����.F��o��2�6�xVn�x���6n���#$�.�CV��)�]�M>�1�~���3=�"��.�/yՈ��.[+�����hL씹3��"��ܲ�X��c(��l�"�^B����C�C�9̈��?���� C�qa�X��;�%nN�#��������"G��/6*µJ۸�酷̪�Ŕ5����f��!vc�i��b-$�j"��O0�	�R�����s}����ׅ�U�_=�Y-�C�"�ͼQ�WML�$�.H�F����q�$��!�ԙ���[x���
��?RV�b�Õ9�!�W��1��2����p���zjݪ$��~�db�V0AN��"r%e?0LI�@����_������&�)ᒎn�-.�ё8�J�';�f���ph�.JD�L��"l�[�$��p�rMH�&n��	�Đbp�fИsh�yY����D���!���~�g��r��O��z՛C4$�%q���Ȑ� RW2��|{���pK'��	�8\��[D*��E����Ԡl��,O��-,�Y��x�2��g�e���	77�$E�g�jp<f:�~q�+���'�H�6&p��y!W� �+3G�J�:$�f�X"!%w��JuM���.��Ip(%)��p���N�2p��%�z��/����j�������h4*L�z��-�(m� �'?�n�5U�;� ���I�<���a}���~-�3�ȡ{��f�,�*��Ȍ��_����f�n��r[$�­)/�Q������!���Ѻ��l81  �2�\���N��DBn��{&Q��A���Wn1Y9�c"햛'FE�<ӕ��+�C�C�K�Xcק����-��mc�`�p֝0�Jx������rd��%6C��4�9=y%��צa�D�,D80�"l
a J�Ûy���Kʯ�6i4F=ܒ�)�t3�]Z?�ً�WYБ�dϺ#��:շN�������#���aDn%^G> � ��b�a���e����8�o&���D�,��zH�Y�O�0��{���x��:y����&I0O��=\hvu'H&��B�X��,��O��؉�o c��C>'^� 7=a��`��ӛ���A��Ɣ����8��uɕ�;�ܽ.θ�C���mM�a�|!�T��G\Nv�P��ؒ��L��b��d���jjQ���Ub0G	�)Ef�i� ����/dF,��K��-��l�*�Q���I��|e�/�%�LQ�%�J�;��XL�[#o�,�a}N�VN�.h��q1�
��%�H�cZ�Q���u��"�<���5�^��b�wY'nO���>��<eaah^�S��f�_������a}#��ސ�,����~�
�$��²<����J�aK����d�����&�a���Ol͞N�o�=�~?% ��[c:��}[��`4�|�4�n�#Mx� *E�'9��F[mb��p���Π�p��7`�ClQd��9��$n�9��U��.��j˚��uU��o^ �)�)G� nʫ�L�^�i�@��F�{���/+�,P'�y�ZڱH�O �dm��.��E��ch	 �o�r�/Nr��m d��j�(9���0���y��<�3ĐN1�,�t_2�ZǔW�q>[�'��+�1`/��7 ��R��u����!`�,AX)����#<:�fS�l��1K�NM>B����F�^~eVe
�&_�φ����p&�G8F��g���{
"q��vཝ�P���"�I����'�fa��`���C�7�B?$�T^-���k���	��M[\���qJ*��܇F�W�W�H|h����Q�=�Zh�n�\8�~�L�>	
�^AebN_'�����n	b� ��@�dhn��#B�l�{��'��x��g�c/���ME�Y�8+#����4e����K��-tܽ��h��+Ң��c
��	�d��A(+��OZ��Զ��J�?�G$&��q���>K�  
k[�e�jĻW�h�5����rQث�UT9�����rzp|��5����������b��� ��И����[�J�Fs(�<�����$��K�Z�y�d�����3�H�}��M2͍-�;:�	�-�x�u���)����$D���O��8�UBW#L�O���&Sܱ�J��y���������Q��o�Q>L�55�l�����Y��}��a�FS]<��|c�o�XمIm�pi��h�$�3C9l�~�t�N"M�D��i��9Eg%|x���� Ǌ��
Е_�e]#������cD���o��1|�'�X0��������C��M-s�X=��೵�f���I �;����Y"��Ff�D'����j|U-�%*-Uɋ�̤QV/.2#>����z&���5�?hLl*�~�.-7�ܻn�����&���A�WQ�0��`�� �������K�����]���,�؁1��N�$6B,#F�F�U    �o>�`�R���ǅ���ٽ&�
c�c3�s�X��Ͻ � uq̾�o���wӤ�>�3�jI�u*�A�����Qg5�$rO���p�ˬrC�Z�e�"J@���Ut�Aw픬���;%���s2��8~�x���y���ļ��=�/2[xz$��7���ȍ)[$9*c' ��l�~A���e1G)��I��U�8��Y
�H|YfA$�_
"H�����3�OZ:�#my�����WQ(9�m����"��r$����	v�BȎ��?c-�\�ye�G%�(�\^,�W�O����蚏6�L�3��=Ia�u�3�:Xrb���m�#�����@=J�_�[˶�: C�"cz�cM7C�:�E��� ��R7��x-SMc���],i��h��{\г�����a+��JaG'X/C�K�*c+_�,�asy�ݰ	�	#t�*������q����U�"�?F��b��Z�Ο��r	~gr�$��%�Z��%z���$#���W�a?����HR�zG4��D�9�$��`:eś#v���evY�	��o���ߚ��p����������#��ȕ������t��	���$E	�,���΅�����t�M���7��ˢ	byx=CN�P%:�	�A��vs�ӆU���x���&!#0��o�ӷ��~� G�g���Ofy@��y���^��F̤�# l'��~��o��<�h��0�gP\H���@�ST�W�)�	_���W�WI]���]f�H����W0�t&g��V��*M�q�$�������	��q��A����<��Ř�b�t�@r��fk�F���e��7�h�qe�Q|��\�Kfʐ�1(�=��u9�Hd	�Q��� �_��隀��PVq�����Z�h�'6)]?�~dJJ�ʰw��ӕ�[0�1���m���_I C	���x`�Q{|@2�Ko��DA>CJrg���L��2�j6I�Έ��rc�.���"�"�yjf9�ă�'L2Y����_���h��ۜ:"�|ڹ�����U4��rU��sr�V�7��\%?��<%�����@qF0���4a5�Puo&�k���B��i@���!��݊8V��) `�'�/Ƒ&=o`�Y�#z���|�����3�Q��M���X<r��қ,FEVv���;�=�c�Qh�v:�$ fg�
$�۾X5	g�h�y���;i5�US]�Y�via� �%N������h�9�X����&�3R�p�����g���ק��]���qQ7L�RL�w��%ٳ���Ǧ쉸�����\�7�gp_&�^XZŹ�� ����}�+��/���Kr�ޕ�/?Qm�;�������'$�h�������a��Gx��F"����}�F���FK�紎<P]]�^���V�@��nB����}M���}Ҽ���F-u���ZYr�폸^�C&\;�=1�u���k�sb��f Y�kb^������W��[5�5n���2q�/RL7�p��$[Xv�̀VX1J�%#��FO�P�f�Ӿ�L>�Q�L�����Ay"����4OA�h�bD�@˳{6�cO 3�������k��6�g�z�@��g�CݒՎ.�ND���:J����.��T�Uz
O����_���a�H��j9c&�|w�-ll���P!�r��/n��7��1H��9��XUY�A���]~����e}=*�~���QQkZ9��Xd�6jٽ%�54���#|�c`}|l�7�q8r��r_�?�٢Ne�] ^M%#�_,[>�Z�KDXg(j�x�y/{p�
�1PY��k���~�B V��#ɜ�lNY�������9��=^��d�^V���E\1 F�әDr?�'��0WB�/мN����G|C� �H/�w%���v��C��{������ڀq}2���sߨ��� �A��˖o�(���gK�m%����|\�vD�ч.+���Mk��w��VGu4�$��5:gU���+�
�[����i��3�G��i
β@\��`ɾ�W�͉
r�"�|bgF(	��݆,F�]�8K�D�jD��5@΄_l�km���N:��ɀ&�M�x����3g�#n������He-�=��H���GXy��7���u痱�b��kv��Y�vU������ʖ�̀��Օ����t�8y�Z��T��H*%�T΢ɑ���z�5g��&!��=s�II
�u�}�0a�� �׷/��E�BR�8šҞ������I�b�NV�4��½$o����y�"ؖ3E�J���yc[�2�t�e��Д����g���	�x�`�L�t]f�F�_��V�P��W|~�l�&�1
\s\��b
CM�2-!���J_BXAYTLW�!ġ��$˱�u'̄̚��Rۓ�B?�x�+ހ�CƢ�n��Bgٶ���ſ����ʆ��6"�A�ƽ�9c�L��x��\q���!�����D��j� ���t`�݀�F2��k�N䈸�)�;&wƦ��\
��Za̕6\koEl��1�/6������Lʧ���/m<�M �� �z���\���x(P��x4��=�٬��t�9rϐ�1y!��>GdK��c�C��Ǫ���[�� �i4�3�ڂ+^��!�zf��������w�PaF�qU��7l����� � ��Z��r&ΝM�H쓜�>^cD��� k���n�D����V��w�*B���e	6F|� Ѯa��G�g���t�2����l~j
T��OU
"����=�s��eh���Y���C�8
�ź��z��~R$��!h�`���~KM�|C�F@PqVć#���' �*Y��w���(`�ԱB�+N�n�<X������yt��VC�0���jG��EBQ9���*-y��cVv�e�{DW̵g��IX*kw�����ѷ���u����3�ĩ�G
�
;i������<l�Ix��6����aa�i�f�f�E���7�-��
u��L�A�/�F���Kڐ4���֤v*/��^��JM&�X�t*F8Jq�1l���}΃o|���_�d��4V��p �%t<QY�&N��R	�2��F���k�{�j�R�b'Nߺe?>1[�a�H���.=|�<�,��cn
{� �u�Nf~�i���pB��]�����I!��"P d��s��j�\�T������S����W 4����u�\���e�v-	8�ߚ<~X�x�2�_u�����q8�^'%!����H����Ӝ���F�r�ʏ��y'��as'�7����~��Y�	��x`t��t��G���������ߔ ~�ߴ�qp�z�;���J�N��VE�϶&8Uϣ��4B�C�dQݔ}��i kh����,o�H�D��s4?�R�2��jX���aXh��yM�p(��"�0@<jݢ76#	��+�Gu��y�������a`E�LcgQsc������O����c�f%��2zr��E��q�bQw�� ���(�Ղ�\w��b�r���U%@,� �W���E�7��.���c�ɳo�d��7c�'v��Q'z��Y�:_��|V���}�t`��z �D�|=���խ�#i����}�a�kEoa���W��;�N��+@��z�[���_xaeK�p���-��tI�(����j���?u���?n��Uۓ+V���8ī����{���d�)�Պ.����Ky��}�0mVVbYh!�u湲Y�:��%���=�AW�8�~[� �ʮ�k�{�_6/!�+Yd��և��˛ßrH%���e\E�W�9�F���LM'��OR���n����hqŶ�Q���n��]�����X|�-��}��VA8����O�?�J}:�9or$TAʈ�`��%�2���T �@b�pd^H���A'?�u�H�T?;'T �J|�V��a��[7Ʊ%�Ue��x�3�GV2 ��[�H*�M��lr���a��PD�U�bz�Jn�k��,By��?Ð����C}���'���B3	h8     �Xn�Oj���D#}R���K��)�vg�T�۝�1Y-��V���{8o��MrM�z��)���G��ꪾɤ�0�.ѤvC)�x�RB���TgQ��q�.5�n�,u4괩Pu�:G�f�nf�\d)�(�p��F�G�tpy�t<#��AP�N�#���l��u�ﵓ[�O$i�a즱���3���g���9���6Y�>�9W����5�>\�m{���e�
K�bU触p����q碾��0���xY=���;��%a	>Lة�c��%�([�t�Iu�L�s��D<�t'�D�WX��Z����h��De���F~h�5�r޴���Wt56�lۉ(1 O�u�#���A��
6�~�/�_[�x�k�u�т	�)�$�a��+�$j@y�f]}4h*ނ<@�h��)�� �Xڛ�\h	l�,�1��r��Ĳ�t$�+\iD�<��Hx\���øX���[�����<M&]����f;��5p0�W~v�i���ʺ���<�!oy�B�Pr|A1���F���l$Τ�-�*|E�E�3�`��`�9�xeR4f��	��?Z��V�F�,�[W���*����5�%(�z�p��R4,b��0+t�ЅjzmV�8��}P��5���E�	�
�$+Ow/���P�4E�S����J�da��	>��$���`����	9��-����A�����:oM��Tw8�ܛ��eƁ���m`� J�ݲf�P[��ᘸ��^P��o�L��.������K�'�c�nĸ�yZ09�Q3d���)r�=��a<����������-��_Uu6+���6�]	yhOŻ�rX�C,�Eh�cF�W�{��Ͱ��r�6���i�l�֐g�y�`@Z�j�$�.q$���Z @������12
޾{ �Ә`�)�B!��;0WY	@�ϩ�]g����	�<@���|���1� >��3��;)�#���g��*4�D}Q���27�gN�g��3�/���[L�58�K�ǏR��-S� 	OK����ad����7��P�o����i���Cu���I�&�8� t���{�DnPC����g&��a��{��&ǎav�4����C@H�� C!Z��z��˃j�.ܻHi�����:Nġ��m�}��aMS�}�^�*@���8��a�����߂C�-��gYl�"Tv�M�-��]�W�A,��k=M���riJ���;���'�B��R��˄�d+�8�{����4�ߠu�,����U��]�BV��;��)�s7�ʼ���$��l�uYN��02�u�l@�T���+X�6�,t�!�h<����&g�� �1x�|ςN��}C�<�^ǖ4�z�`��I�?��ܦo4 N�tx\z�>�yȖ�TBc�#Y*�U�vu�^R4]����LS�p�S��PcC�n�Z�h%C�Y�Mu�R� ���Q��M6m��ޘ���C�wL�y�H=�[�j�@��<F+�i&R�Q֊��}�����K�`��b�X	�@�ӧK��<�fp����!o�7���]>C#[ۆ}Y����`�i?���ywр��_h���!������hz�mY �7��9�3^4ƾ\8��J��>�,
H�~�/��E�JJ��@����I�,mN��P�������Q"�6{�I+~��z�2,9��	�@ި�����8��E�5���mr��S=ܦ�*��<Q�a��S���iz��6/����'+3�H�d�h�N��Ò�cM?xP�ʥ����Ӷ��P_��"�eGK�*����5�͆a��X�aZ;�[�r���=�.W���{?c,gC�=l��4���ٽc$������sc�n^��7�L ��l��PB���kj"�����	:1���͐��L�2���b�t�L�������7���jD�ख़�,���Y���H���0�4u�7�0uJ�JD�J��6���sK*�E����_��#����wq%�s�B5�D톾AR��	):���uj1&�!���*� ��L-���Y}t';R" p���/����d�&l�s�l�.�T{�'�T��`�L
^�,'��U
B�m������pjc^=SdU�y�S�5�s86��v�W>f��H��Kjo���5���D2H�)�Q��Al�k��oaj�`�wX��S�P���dZQXŨ�6���/�Ǽԉ�3�	��X���[�p�P M��R�'��fbZ�?{��*#(��x"G�����K���-�5}�o�]�t��i���jԸ�>�Z�ٶ�bc�9�y!_O#����XE-��g�̌����ҵ�����O}�~�7��-�D�7��%�A�A�����@_���`3����*�)w� �1	U1H��L~��6��T�,�G?�kU��(ˁN'V�/����t#�H�V�&څO&�?dI��}���_�3��P�w4�>�Ȍ��RR�"wj�t��˨�a��[F0��׏8�&��m-�����#�3�I(�BE;U�6K[��qa�*l�+��(8YZ �-I�k�ηݲ֞�荘�J�5{�V�FN��?(R�1z�D~EK�.7,��V�x�M���� ���Mh��XlOnV�3�3�=Y�@�$^O�LYF.��4���S�.M�������s�*R���?
����9��o�����ϲ+��R]�|���)*d����VwP�YX�&n�2+
QaM ����[r�,��Iߎk[��&:**�@\utg�/S�uo2RWS2�R��ԥ��A����e�̗ֈ{xb��ktդÎ��R���M����z�}��S����i�_\AY�,C- Y�z�b�
�B�"������9	�3�MF���N�f�e8�B#��'�PC�1
@�¤4'd�^�2=F�L̾K�d�cޛ9����-��~3ݵs��"��=���f��d)�V�����%�3�,&�c�����/�e[ЀO"��1fv��ը��V�zct��Ň�+�r6+�o���N�h�5��Å�my�$A�78��"�A�J5Ɖ�M�x��W͛L� 3jVEIz�өW�A�^��h�ģxO�uUr"d�D|�9�Ra�ǥ�{�Ylz#L��\j���Ώ������#&rX��^�n�=P��w�o��(	�Yi/mH�z���!R�0�e{���!���y��<6�9b✲���0��bM͐�G�tr�	?.�����I��R].����\�T�5+�����v|
�K����BtS [P��6�)چʶ��8���h3q��i��I�o\,gn��zp-��?b�����+kIa c�VD"��|vVW��ġqvj���*��L9 @H{��@��sr:�8Y�)�~���~gا�����1*���4�Ѝ'7����Y�G�j�J܍6W��� `�h���yM��!�Wث�S_WR�Q<�h��~2uV�T����!4�=9��ϤJ2*y20�Ѥ��A�N"4j�&��|��3/�����ܪN�F.<�{�����/x��q�����+}a��DӠcv�) |K�r9M�k?-&�]R��M�ܠO��֎	�� Ą��U��躾N���Ԟ֓~��ÜȢ�o�O�i��<����0�w�aN������v��.���ڹ�cL�˔���D���:�f�^���5�Ƒ�o�FU>�ݴ�RCn[܃�h
tI�0;JM�L#�#���B���� ,�@xr�-\Y8� ��9��b	�ww��E�W}9�� �J��B�1�^ ϥųg�X�;�_0�Q.�
ϝ-��w��u����ش�A�m��g�8�5�&�0Z�m+ȏ��%X��%�����ˡ'k?-���נ6����0T'�o��og��S�Z�3sn�K����
׃����j�Cs��ݥ%16wt����B�k�X�[(-���]���(dk��Jm2@�Q���!��P�d�R�W7�1�����ڃf��Ql�mU|�h\q3M�^"�ѷ��S��4����^���    �m,Z�<�� ��<zQP<C���u��ϥ�q��y����.���E��u����Mītw��}c0��<��cA�������`\�#}�
����,�kQm�w���>o M�?F�{��e*��B]�s;:?�qM�R��@wK�9��yWQ��J�@��)�H2&yw?y�8� ��i�b+�lrDT e�ӗ���H����QcB�}����5J>� ���pb�U�0�9&:|OBKTҦ�����ѐ �����"���v��c�bq�)P�Uޠ.�#H�	�K��ee�h"��~��1C��V��4�A6+&���v�6D���tg`,�H��ȴh`�m<�����J��C�~T�h|�6�Dd�Y7�$��Rv<.�3t�P�J������q���Ա�0��=U����%w>�F !���c蠡 ��G,�S�5��A{mƺG�b;#x�C�LY���:��	�Wnl��y��Vٛ�����2�N~`�e�}���y):.�W�3E��s��P�� 9���	$��/(�s�JS$�:f;"Ď~�^GEB�ȶ�`F:K0�ao��`f�@^u+ߴ�o��W3*T�wV��t��p�oOrn�'��,������0��%+&�\\=t��ϖ;�Q�o��N4"��/�!b��ӌc/V��_�����vG�vF(������a����@Y{�ΐ������JX�����/]�	���z�l⫖����k�B�	fˀ^����)Ϲ�8�~n�d�`B���Y�zx йn���!Z�	�tᐂT{�D�*��֕���fm�n��?'$_P3��d����PCL�����0��v����-J^�u�m�7!�>u�L4Ce�J��u_+������ov�<��)�+FEB�Li��˽Li��:a��3&[��f-�? **m�i���8�h^�Q�gm�vC����4+($�\F�p�Er�z���cƖ�Hk<R�y��<������FmGj�pV*y?���(Y�[֕[v4�)��Y��O����2�P�����J�ض���~V,��m�I(a�D\CC>H� �Vm	'P�ZՊ���[Z0�����F�ʔ�_bӌ�Q���ߏ�*����z�g��B�m��p�L��������c�(��w%=��cxc=O�t��U�yn��_8:�r*awe��ҘB��1;�İ<t�0]�}�+�m[�cP�M��6�rB��[M���#��=�G��i�$�YT� �`^�f:�~��č���6G|$:2)aO5�vT`/�+ubG&�t�j���:�"'G�D:�Z�M�`��4�r���01dվ�~���3���c{�>����W�:|�v��]�@��#��@�r�J�%h��E�иCY%��<��]ȅ�	�xZ����P�@ĩ��I�@Sm�k<�����'���8�a��t��'+��Q��8`�T���sԬ�c�4g�ȅ�Q<K9T"��(Ԉ�a��V*���َ1���SdP�d��'X='K���Ǉ����e%��m�rv���K3�0t��U��I�L�?�P�v��g��LFW����U�r ��f��A����V��Uh�	�µ�R�#� N֍��/�bR��a�(7"���SS���'��.F����ۉV�V�}V����wL�c���gR6.�	t�IKK���$��~ ����j1JQ�dT֎��/��}�h�T<���A>>
핼e�ʍ-�)Q�^��ͼ]w|p;�X�6l'�`m8��]c�z�Qy�S��,ثS�)�[���J��]��M��������M�o�;[��E�����B"�]�()�I��T+�
/Pɂ/�z�T'f�5[�+e�筠n+��bɎx��8p�� �ǉ@@�N����-,��yJ�D;�Y&�J�k���84D��	��VN����6��B� �-�����f_��b�V�l�	�/�[�L�rE<���?�>���P�s0�Q'��l��8,�HcT��:�~�O$X��|�@_ܠ/�!�.��*�v��b[P���31��,��U��P�δd@���+�f��?�er�o��h����]��w(5�Dj��n
;�LH�n�4������ý�,BY�Ƨ��L���k���t�.����NBY>U�U���u^�,ÞB�JD��İ��S��R�0���2d#�߉��X�U�r9WV]�X�g��ojw1���ITL��(�d�����A�'�}����k��z:~��w����`Y�s��W���]K凪�P����L"���T3֙���|D¼�lIp)r!?DPH\�퉇���`8�Xxߔ����}.ދI%�f#_OJ�7�g�z���z]�Z<ߌ�;�[�9��c"i�L��e<P��M�G����u_���XKf6�O�3�X(u�0?n� ���<rJ��VyM�Y���Ԧ7z�V��V�k��:�@��;�4�V��NC�d��LႰ��˳ק�"&ػe����ׇ�W����-�~4��2��/K�$��$�f�+��>��~��pж,-��f'��ߡ3��bD�e����X�f4U����8�K��1jr���٘z�\@%~���Q�$�'�<�|�"l�QpO*v���H
dr,z�>�Y�_�e���Rw5��)Kפ6zFL)b(y`~:�����axb�M<��Lݵ`x5�;B�5��t���9-����0���w�}j�ۏ\_��3
��WC�[������ն���B?N��`�1��Y�)�1�#N�N�M�gd�	=X.�2棕qKm�ȈX���gY�ߌ<�1>f,�H:27��/�[5a^�	ND�#���!�Cm�<~�c�ܨ֬4��gX����%	��w��� �b��2ǒ����V���f�5���OlZCR�]`�Y���6 �+���4+Ϩ=޹y��Z�C޴w�<�&��ڿ���π<u�֤�[�� ?��X>޵UG�*�&Lg�Һ�\�O��� �����.��G$Ϳ�+���(BN�E�i�A�`��.���7ERǎ��<�q����;���+6���͡����tu '/ڴ�J�邂�Ŷj�m��H���"�E5�g�G�����l��lN­�:���J4�b]��>[����*� v;t�Ub�l/�z�ƩW jCx=��qzY��2�C�Ɵ���ɺP=�/m����F�@���(8���L�d��mp%��Y��>��AA�� �J����$"~@���j������nJ(HS�\��9E�P�� 
�̕���Q��X��%n�✪�K���y#4
p[;zֶ_���&����rY:���[xt�15��d~(��^?����F�՘al3�9�� ���ZI$�]��^�����i7�)�ʛ
Jh���T�_�`�`i��=B�r�U#��i���?�*ĨĦ�����ǟ���ۊPD�ca���qM	c�xG�G���r��׽2]ܜ�����6�j�v�rM�c�:�:����4Y�mv��,���n${��=:~s<�tnr蚨-ny�|_ր9�o �v)}�k���h�Ү M|3��pNT�j}��>̓e������4�d!�G��S'ͭ/V��S�*�Xe6S���h�J)���J+-�4*�+L�#�y05��x�c�p"�z��`\,��˜)�%F©�'����I$��[A�ɞ�
�(G��U;Pԑ�Rc1.��SH������Ŀn����G��)4yô*��
�� ���jT�l����f��Z
��vs��:n�\��b;�cp}��+W�
S&n����qy�%9�P��A��32����N�
���q7c���U9`㭂5�(�D�\��)�����N�7"��Ԫ%y1��6���k΁&�JN�GC��$���5�[ㆼ�r���cl�Vǆ6r�am��W�0� 9�h������_�,�5��s��釿��s5L-'F���	�p��q���i���c�6EeS�8�M���:;��`[7Ul�����|!�<���שp@by��s%nM��    nVة����P �&Y�����&�w6j��=�O=�������@�/��3e
D�X��3�P����>��ͰR�s$�TONm�8]�qiZ����-�A���;f➔(/S<v5w���h~b�L�_>����ie��� ��Ē��eL_�+�����X�^ȱ���b�6�CH��ކ֧��A�Hs�t~�� c����R�h0'7���C��ҍ2���ö���B6� �Tozl�#��~���Նk/p� ���Z 伆�D�f� � "s�n�]@�K�-�}�Dt7m�*�]��ӂ,�+��fR�C����8$��S��j,9�)���*�"YZ�S=�fL`}$
j��A�r��\y��u�ڪ���	9td/�H�6��P����{����2'"Uf+�G�\uQ���r�����;����)��AM\lO�_K�-�_K/�U�x�I�����Ks��j��|�;���Z��?V��!�䐋�k�o���I\���Z��҆�������r8��%�.M�+mN��?��7�9���Z*�\X��tp�o���	�x������Q��i)7Y0{8���]}���5Jk��+����T!��H��/�}i��{���Q�Vi\���>OJ��L�as�,-/U�1M��V���)�� FuLAX���$^47^� ���Ϋ�W�O�H�ޓ��� �!'A'Z"z�$`q���xZx- o��):U��H���2�̜IS�k�Ax�B�<3�V�U�D1%$�����c#ȸp%X��j
�ɢ�r4h>�]J�����d$�%v���1_?u3X�'����WY��K��і���������"�3�8L*���a�{Q&u�h�=Vo�m�\>�-f���g�׵@��obr1�Z6�b!���v0g<f�À|�1����e�x���L8�ן��P�����AS�b�:��Zj�6�Y�}���B�:b'�&��]�#1���A���^H����+��{D\L�qx�Ie[�+$�o)��,�,9P�Q2H5�B+bZ2�:�Xߴ)���F�[m�h2�ܹfW1O_��w���6Ҵ�uE�i:�Z�[�'�H��8��wy� 蒝hۈ�Ms=�f����u! Y��uT�:e�*�~�0��"�u 'nXkS�vd|��+q�5hi%���2mq(���:�A�M�x�YP�|��hhYQ�����c��a�1;��VTs,��VHo�~K3r��Z�|C�#�����~殖Gɖ,�r��;%Zy�̠��&�� ��ߟ�ȑ�HE���xQqO6h��Z�h�����N���yDVк*�y5E�X�#b�BTǰ����25-ݞ.�D<��Fw��N*�[Y������C�`n���UIZ��If	q�E���j�A�W��8����]-%e�o�@/J����Î�Ej�F���ߔ����h��׌��I��Dğ�xj��#�Ę
� /����y��1�R��n.K�+>F�"Z�0���D�ᾷ	��I�BH�����v���iL�^�lsbq6����ܝ�H�Mp"_�P�jr����:V���]�I�v*�r��mI�?��`2�ooXf9�i[����������v�y;8�3��2��}���͹��'�^�,ܚ�X������]�od��b�߫28��h��n-��C��(�t��tt��R;�,��M��O
ݾ�ow��˗&�_*`���*o�{1��f����6���3{Y9�}��|
.E��i����+T�n��Qk6�1��2Ux��\�s�����m�J�V���=Ә�� !���IЉ�QtrSo4����%����1����M&?G���C^ȩDv,�F�è�i����ŞJН�ڟ��f�v�t�4oS=��HŹ��.N�gw1d��&ں�F�eI ë���eǇv�)5��X�|Hzښ�A�����ת�hT�5g��h�Ʋ���*��Bx:���q���H���mª*� �. ��� Nٯ�=��a㒎��e���A�V���Kn��	���l�pl�#=l��	��s��Ņ@�~�������"?$ݕM��������~L��� m��ی�H���#�X����p=Y5�}�Δ�* z0F;�|q&@���*S����Y�Y`邹�X1b�9i	�<�!ޗ�6 �1`���<�4��3<7e�j�~����N^��\2C�((ͬZ!����6���R=}�??Qx�e�[,��_ў�C[p�RM>��x����I�%�ig��+O�c�=�&э�4q�z�t�xi�������|�S��F�)��cC�,���s���"�ik�5��U�n*�=�<*̠�q���� c��a��gZ�鸒�g����.N%�x̔�����6� ��~�"���G�@�	�FVBfדb+%�5��y�f�������]^�d�y�f���������T;)�d�������a�\a�F����ci7�[���[�~��l{�~�#���������K�C8 UE����Rgf����	 �E��ͮ;��S���ק�#�4Q��~(��;/n" ��T���,�)c'�^Ԫ�KP�*����22Y���-& �����j�8;5�{�|�1g�2�N���������%��4Qe�UV#�p�AB�jb)#�sH)S-7=��@#g��$"蘆K�	������Muͦ]�묌��<!�C��9[�;}MQu���#u�Y-��v�7ߵ^f�C�9l,������GR�.�xF��/�������Eg٘��Ɏ*g�����Թy4��R������0��ƺ�UY}	:�g����<���?/�8�|@Q)ṻb�8���%��$��c/��C,�N+lJ|l�@���mV��=��"];*�����Y�($3M�M��s>I�vΔ��m�#B�w�X[S�6����Kū���V2[A�u�g�dGU&�:GV�:�Z�0���
��4�ʎF��mT:��ā �r�&��萝4Q2O���=Z����T�@Y�܆��9=9�+�[K����57��Xlw�]А�(sߪ5x�X�������|�Q�)(����I����Z���`5%�ˆ����2Y�o1C���c���'��4�P{ת�Y먷���U�,:��у��-���|[7Y3Ĕ�����|g�d�R�.�~W��5���,^N�t��5��B[�U�MO'#�hS���?��ٕ�Qjy��Y(�%N�pH8A
9Y����+Y9a�� ���sjV���)���?�)�Ğtx^$eF�E~���p�x$��sV�~'��:����7�I��O���NYޔ?�9�l��E)
�/y���WCX���zYڳ��A�{�1.�l$ �{<�������[�iַ�PxHS�\����jj��Y���kX�~��!ܺo��� ��/4�fƓ��ۀ'yczx�9UX�ZF�Z���_}-���o�N�?k׹%��C��NUc��V�5c�l�r!l{'�P0�1��%3�Z���WK�ޡɄU:D�Q�іbR���@����$�~-[Y'��Z�g�BF3D0���]��t�)�JG����ˬ�=�c����]��BȾe-��I�-������1��d��L+�����F~-@P$�2�Yl��d�f�pstx}9�������7�������_0����
�e�$�L�T�#؉o��!U�4�#�]�)��&�Aeh
5,����}�����ZL��R6��Y��W�F�����x]k�PT�m�њNs�h���%��ڧs
2��X���X?��Ɨ�;�s�w=�<`�A'R�S�7v\���:*���t\bC�wq������������������,�ڻz`% ���+F0>��a{����y��<F�2�4*y
E��8�j����??͉ୃ��d"�*:uX��qĬ%ß#{>ujT�R��+ݭ�;Yfe;]�M��JKk��=���z��&@���!@��`�����'5C0�-�c�ng2���ZM7�u�,͚"G+LK��)����s�b��Đ���$$�Lڱ    O���`�H��
W���������*�`l����'Iw����K��Ԡ����^��@~�+�6���lֲ
��u>�=V4�D���x�N�:�/�H�1pN)����>-�Ϭ�wEy������A�H馷Q��I��2E�!�"O7��Q7�����bH� &�}�K�j�Nj�ǲs&&KK9% �"9τsG�?�T0v�1b�[�X1�-�q��m��1���k����!�8P�Z��լ�y=o'�Sa������S�7�ڈ~�`X��3�)�W�+�߅��]n��<W���?������C|�%��&���ٸ*"��a0�L�x������g'^z[����@���)��yW-������h ��9F��L߽VР+v"�gd{`BȖ���t)�Μ�Ž��m��_W����a��d��o­7��ȩXq�a���c��"\�";i��m'��(�SA��d�����'Q�_��.uf�����Sѵ�mx�����m�`��|̢D���N�b�������3H`���V*��Lנ�=��>ﺮH�0�.#�g�Ъj<���F���c2Yۯ8�]#[�&Q�Hl6ب�e��wX1qm)�6w�R+��kl��M��1N�)-7�]�`���O��JЗHa'c.OPUs�6H�z�2b+��n_�����z4N�D?N��P�V�&X`��Ey��M��X��(��>��<E���x�n�C��dPgfԞ��KO�j�A�؊6(L�m�h�Z=;�j{E�B�����)�/9�ї��}�k� AG��1Q<�X���PZ1!*R�R�iW����*j4z�{[Q;="a��9+���	�����Ms��M��9w
2��B�� �5��$:�;7�3�Zn�ApJ>5��*�(�Y�nS�N�悖���Fk ��Y`e��c-��(�h�ml�h*,���̛�Ep�
�}&K*��a'����b�`i��W��*e���Q': "?*U�N�v*�O|�mU�{�kY���-t�I����q���ϧb;@ˬs�����S���p�}\�����4�W�N� ���qKb�e�}NV[J>n��1?�99`�D{}W��J�������DYC��6��`Bm�ｄ��o�߁x>illapH,p*3�hq�)��@�D��xr�<��@$�H�_��*]}:�����p~b`ˬ��)4w �%N�<2�Q�b�j�Mwh�A����iy���v��>\�Zڥ�ɉ��G��7E��n<�0�9��G�E��RUi7����H�������$�ܕBޢ$T@?|d%�´ŀê#t�o��ҴgRd�jq5�MUn��k$q5��1+�swZn��pP׿�n�[�WɈ�@��Y�:�ˡ-��n��}ڦ7]���ä���7��Dx��˸��^ɦ�F�y'i�0VO����e?�X�j��N��9N��e"�-'�m@4m�	P�쮽�Sz1/�I
�Hޥ��=B%X�L_ i��wTp]T�T�����]�s�x�M��p����XӅ\��yZQ��I�ݐx�0a���� ����2�!Ƅv[n6���t��M�W�(ؕ��ʆ�yv���Z�i����ث��N{cua���K5be�����+��a��_�Hᰴ��9#l\���N>O�~�f��KհC=̢�gC|�$�n;�:�_gb���K�<�n��I���hֻLBRp��_اe��k�dY����.I[}?�����Aݒr�u����|�U,�*�U�e��%���(���D:�0�G��!��4��� ɴZݳ��6�U�l?i`b=��k�Xb�10=�\��tc��b�9�iMĹՊ�N4�O�;%e̫m�)b�qޘu���+�_6D�n�Qr��BA�&��<O�5 �-ZCr&�C)�wYO����ՙ7�-�����L�)�L�r)Z�2���*�8�=��d�pJ�,�n�D�.�q �pA{� 
@	(����> ��d��􍗉T�s��4���#�::�(4�0�6�%�'�S
���iK���V�|(;�P%�FY�%��/���	{g�8 fPҜ�C�g�d�� ��;�#�����*6|�e$�4{T�A��Ю
���`�CPKv�����?�h���+U%
�pR�M���^�N�b�`)dW5�&�W��֒c�֠ۨ!�~$�>+̫6d�p�"����J\紼����0G[+�✢�x-OF�͐�߬Z��-�
��<뾥f�4m$�L9������%����՚�C�iR��4NF݇���z,ۊC4��mj����]}b&�"F��F� �L$7���UN?\�P[0� ],l*�����&���a#sQ�P:i�ӹ%���|w��T�4�rm7�mW����H]�F��Qx�i�0�3
!��f�G�7�%C���[o5d �$�EE���/���`�{�aA�>��!��s[�b����"�bn
�x��J���= �δ���J�^d�)����\àw�{ΥՃ�z���DF�"�4��F3�n�!��1�*~ �ŕ��r;a���zT�94�8��ؕJ�\_����xxϣ�k]L961J�v���*"��9����<�}�����>\��_�z��f�S�/�a��4��-a
�Ay�9��e�4�K��2YI̴7"zX)�֢�>��C��(��J��J�M�*9��]|���g�=�gS� �
Ͳ�w!�!�%��t THy9z2�j�͋\�l��p�58$5D|n2B'6�ni=��
���,t�H0��z̞󟊈 U�l�2�� -�8	�C���$�_�R���w�;t����*E��C> �N毵�8]��T�Y��\'�"�L�	 �� �0�q��.� }�~��t=$��m7���e}�c"��ڪ���,M�%�U�T�FY�v��7�TUAVԢ��q
�v����GE�Rs����p�^0�K��z�O�Z�=+��C��v�7�)�;�I������œXh2���'�	n�oڵ88������B�r#�t�'"vgz��w��@I��u*���λ��uz+ �5�&�bU����T�	Q�n������q~���9�����x4.���)܁�E��*�]u[@�ݙ_�XJ'?uYZR�H���հna���;��H$3�|s�%��Yr'7��q�|�'C�;�0��T�����x�2B��su�$Fǅ��m�	�$�@�N��/>X�t�6_h���7[줢��N�>���^����@��f6�@��ʞ]�>�4��h��Q;�Q����Kp�����
7E�ŵc�����x�ǪQ&s�@�*�!qN́���a�'w�g��'��0{��]_bQsݠ�"�����~Bg?��V��n���?���(�<b/��w�Vs�&�
:���l��*�A�?���H
�֜>��@:�����#��ʿ��J����ӊ����E}��ٹ:�o�c�Ŗ&%��9���
uG��A]f��	�����S�n|,>:;��AP���L��Z-������^%�K��>Rӑ5ަS.��5O��\��e�Y�L$�0U�`�[Ïi>,m/�;�_�>��i�#'#K�yY�N��*C���cxq9����k~e�{�d��L�Ȑ3�I��w�%Q�nr�ϽnQVF|�k�?d<����j���;-gu���U�	ր�b�Ֆ�j�bu$������Z:н�C�#�b���[u@r��mϥ�U���c�
�:U'&%��"B�?*Pl�0DQ�/0Lp;�$��553nG�&��rйtK$�@u���>*�D��;KmS`P�o4�t��� � �����`��s���ޗ��`�h��+�t@�*_�(B�P���ۗ!ۍ��33a�k!��ΞԽ���y�&WG�Ns�a�1�OcӚ�*
�B����X)grd4Wր!p�g�)�48C�����"�\�f����f����������.�����<#�����&�Sd�0Pˍ�7 �E�th�����;U�<0��    ϴ�%*�W�L�m��gR�FfG��Ry�o8-`�w:8�tcVbZ�e����Lf���3�-RF�{��SQ퟼k���[��c�£������3-���QnR0�y<)F����O�2-�fW��PI,gmY�P,'�o��Q�j8�W�"F�)̀�җ�����-��a��Uv_�8a���#����O؅�r]Oc��~b���4g[��e�׼�7p�M��T�z���Hʧ��#S�\�5I ��`�i�a�0X��7�K�K�����������dO9���V���I�hc�K�X�-��>���nsoG�pmAYe�����a�s�q.~aK��O���d4� ��%��Ĝ��H�ˡԣVe�c2�'=�����ς��P��h�t��X�Ԟ��0X���I����Bg؄����8�Y-�/�h3R_Sg�
� �E��>��=�!c��dN����vo$@��sn@�ly;�D~t��3kW4�MV�\CS[$#���W���kR$���B'i"c8L�ݮ�,������]�/?���<��=�rtH>k}����78� ��a����pRf��Y"���b
C�
��~#�A7�=���uO��^>Uo����]��>��+RV�q�y��"��v�5�h 1�Fk����`&�F��Փ��i�lw�j֑!�!�3���g�c�cNg���q1� ���ěS��Y}c
�A�]����q+��u	����Í3�M%�����EY1�C5�Mf-l�:��A5�L3�{	@�[�u�ˑ���#1�Q�k�$�\"S�3frc�/aDFLbkT�� D:�De{��E��EH9-��SqQ���K�'��Gը�a��Ժ��z�5�N�ؿ�>CW�r������d�7A� B($�X5S3P�!��c�|�94��JE'`3����|h�nR��4:!��Hkq�8ւ��Sd���}����P�:17 ����Aԟ̭L��w�s�}]���ɡ���,Ona�c�G����n�����=]m��⓫�V���!D���n`��y�m�Ʉs��-"��e�"Nw��Κ��^~!�;1vҫ�z�r%cK�v"l~/
2�z{ϵ�2�h���/5�gq*r1��=b��P�i�)"��~�w.�7F{��5�D@[�]lЙ���&��X���lq(�4�K��)cf�,�^6&U~T�Q���n��a�d$��6Af�����9�*`U���ޫ�_5��qC69�S�8��Ԉ�s���a':�����\1�:T����u�S��';�y��3�6t�c\���Nd�\@�핞7j����=x��e���1��$�Q�4����pT4�}����5FF��r�!N��>s'n�7�}|"�I/��(�̝���sFq����h�u�{Q��#P9ż�3�\��\�nt&�q=P>�)C�1��e��I���[K��V����U��̞��c�$&�P2捂4!�kH{yb���^���<���pgD' ��5,*�/�&�y_П'�2!��9�Y��`:��<$�����<ل5��J��Puj��ӷ;�X�xwe�b�v��th�䔃��%�)��6.�0�,�����v��ǤZ~�B��R���p���朜�扬`�{�l2:���\�d��YU�z!>�;ƅ��p=���؄U6����!�g��kɧ1��M%6�u�A^�4P L��d�̴���d�"!�>�ȟ�x2;D{p�{;�r�5���Գ�`�`���R^'z/�����Xc�Y�p��Nكs�Q)J���3b�l��H��"9��졏�D"�i�"�L���+㛹Gs$�Jb�[�~k&� ���쫷d��Hh<䣐<лr`��О���R�^`�D��8 }�8x,�A��p0aQ��2�ѥ��=�B�գ�*�X�[k�D�$')db��:­�=����$�<�0g���M�
i
���V�,==@�-o�:��eD����I��WV�n���̅���:�rnf���>Ű|<�7b��i ���/w������|�ȗ�����o���p	�Af�'��Vn�9���)͘ /� ��Q�My���U�p�hvB�$G��
uDr�+�+F�6T0�����a��U"�@�:&8nm:�]���Mg���CX�,����>��$��&�
�7̣��t�:[��чG"���xU��P�� �%�Y`���[���d����؂»
^Pe�踻rH�J��uE����vh�&Ge�����^$����ӿ*/����Q�Ԙ!'ĔH]�kҘA�����%c ���;J�pO�db�n5ғɈ�2>�/�u 9�+'1���#x��g�	�Vɚ��W���x�:��wK	f~z���Ÿ�E�����F��M���/Y8�m�e��es.�6	�X=�>L��=�G�����ƔA-�'�wC�!���-$�x09�w��O�Ly[yRy�	h���坔Lo���/��Q�%��@|����7�ƣ�&a�c� ��s��H�ē8���S��OMI��p���/Y�U>���"!���(��:��/�D��$�ɍ��X/K�3�Ĭ�F�z8�^֖���)��y�Ż���2�Y�>m����3e�N-ԎG��Y�r�ɶv���6���M��<(t�%�ȑ�@EU�>����@X����	m,��ddGg�Ɓ9
�oSٿ�bb���<fe'R�R�*I��P�N��+�3�u �4���)�I\��'f-�%y�*l����7׸T򻆎����V\��N�*�׼�J%��&b
tuU���x��nJ�����Tt30ᇝ�y�8��4��d����~�;�ѽu?*CDh�Gy�
�E�U�3�yg{�v)ݳ4`kGY�$�x(�#N�
���8��I��Џbb�gv�#{���+5(F�g �'����n#��}��`�d��sq�qyn\����%}�Qv0I�l"�E�VB�m�_����Ƿ]��)y`�@D<�	��{}�8�=��s��P�g����k�\�Ojӻl����4}c��x��卤zq~EFd�IAp��C�̅�G'	�@�,�?	K����t��.w�o}Tq�^�{�R�Z7&�X��q��;ʫ�Ƹ�Py���{�8��}�ߢ`�H焅ո�yu	���a�Bo5��]�C)���� �eQ�P�ZފFI���k����U ��yՆ4�8�C�9X�-$��v ��� jqˇk3�+&��b���r����jw�J|
cɛ;;`ܵ�����@�۱M���h���Ձ��z�3�Z�#��)YP�s!�q�d��������܂��Y%z�����E�<����t#I���&�)����n)���/+���&�(�W��d@���by{&8)+�꿲�?����5��%mXvBp��hA�h��Xtm���m8���U�9.J�B�"H�T���M"we��0���˫�_M�8q�Z��iB9l�B�t��2��<R~��t6k�q0�0�<��io!k�&�B��L#��-���ZA�Z[�h6���Qj� �Q9�l����,�@�~7\������m��I����k�_�g�H'�k������ҏ���,<��#+3�:Y�O%m�B�A����wj��8�̅UeWh�,��u5T�65y+j�$��2��np��D����8���Qד�:ע*�sng_��;7)����t��m�W�����ep�H��ZL����죰���^�B>(�1�b��|SuL�D2��n�]N{(-�<ש$��=��'���6��{��F�~| l('4��[��U��KC�]�=t�`�̺�GL=���B{BbӸ�r�E�PX��N�I2���E,��f�Î*Y[?�����-�lU�^r�k4��^<�@c� C�cd!��jTc�n�r)��ic�'^ۿQ'�3�%� FF�?Ժ�_���0�L��R}�Ū(���
&:R4���V��L�WQ^���7��}�[�[��S<f/�mM�i
E����MQRӟ� oӨ#Y�I#W�a}�r��Z���Q����v�    H�2ŷs$| N�������pQ�g��	�2�3~ �G [O�?eu�
�G���8�u{�8���A�"�<S51M�+�wDx5��u����.�==�,�8�6����������<��*�-='�$D��[� aل|�\�BG����\o	�r���������Lgy_�l�j���L�C}��.�J��#惙u��/�U��ą&YC4*�գ"�(��Gl�����:K��0�H$��·�K�P_A���Y#�~�=�������6B<����f�b��$��s�ɀ���M�Ia&0�vW��􉜆���
]2��lс�����e'��^t�e뎣o�T}�1!U�VR�a)�:i�tL��|�9q11r�K���f��xW��R��T���«����_�
��j�z��,�S���Z��$�u����ܰ��^f���mRΩ�]�y#��s|d=HčWnB#i��
����f���3"��Hf D
;�d��\k<�Dr��o�氿ӪI��"h��U����yt[�=�sJ�a�$���Wi��[E`!r��'
UI��݌��Hv����
���","��[R���9�Ef y�u����,r�'@�K�cv��}Y"���&?'��┋Ŝҳ����V�8H\Zɪ .꼆zZh�������
��1��yi��YR�lO�p^���~�3U��Ǿ��1�z�E����ټH֋z�����>�q�C��,��<�\#5��5 W8J���K�ڨ�lв�V�?Fv#&���(CF}{��4��W�!FA���f�`\cȵx�?��D�)�n��T�n/���'�G[ �mǟY,�rtu]��&�F|����2C�]�f�#����)r+���ҽV.��%߉x�\(C)���:��2ּ΁
,x����^��ɥ�d���\ޑPt@������~+f���VdQ�K � f�^��T�	�QǾ	����� �� 	7)7�e&�&+؄�����4oA����z�����{�t��������s�~�!�F�f�h��C��h��/��{����>�b����k�-�l:�o{>����	ۜ�s�i�A֑��җ=��`�E�	:_�t��s{�+`�Q=
\�0d�2,ܱ�~z&�|��Z&H+���(��faI��i:utV{�y�E���Ǻ��!�)"�>�n�b�]]<��kĂ8g�u{���s�]_��"?�{�֏ct��4.���+U7TX�)
ZH������G�nU9'ʫ��$hf�� \�l�:�B��8/�~$0@>�uS:$ �T��U��f��"����Px�Ԛi,��e@Q��x�[ݶy�x���>�(������ů��A�~>������=�H��OO����|CDx���5g��Xɬ��4�:�s�X=�e`���x֠���C�[���̸U�7�������ңB�������q�H��oYsls��"5��`�녱�d�5��weO�J?&[T�!S�C����!�o�=��r����"��.���M���t�J�֦�Ջ�&�l(��~d*b:"�	��'���6��,��/uc��='������E&=c���
��ʇ*)GQR�
�g�(������V&������dt�@� �h?7F��r�Y����PJ{&(�y�(�4z\�^,"0�-���Ad����w��&8Z�uH#w�!���������@�Cv�*�����i���f7�����Ϟ�Uau�A�{E��y��1�����ү@��y!��C��6WS�����Ma�>#���[}]gҟ���l������"&�W����`��m�"�����	�5�cD�m��tJ|2t��Tf�Lg5}1��������ZbP�i���,��H(�}?8h�Pi|+���0���nR�y�G���|��#mcK��s�m�h�X�G�O\��<��dD�8�'��p�qV0F6���I��V�\8J.�`Ge͆�;��y�����Mv�C2y�][��3��o���F۷`��ȇB��ݪڭM`�g�9%�U��G
͢f]mZ(DZ[������q�!��ɻ�j/��Е$�߲�
E��_u��U��{�[�G�0pq�~��a�k��*\��W���}�/�j��a�E)��Qd.����p�h�!XS�%5�`�$CM,)�G~I!�K�PJu�w7���b4/�B���Ц��-V%�%����������>J|a(��b"�g�y>�Md�ġ�-�lNY�j_#^�H6Ǎ�oe��#Ι����h魡�k��� �+h�Q�`x���޴��u�a/���3*
z�ʆ�ڣ7��k�$�nڔ2!�6vHI�=\]!����(P5�+q�tq�o�����6�D?6���![��1ێz=N�	�u�p�Jz_�HШOz=
���d���.a�~��M��q�>sw�7e��3P�2)s������fen}��(�wfv.tAP�
U����޿XP��s���_@E��M�Ű�����I���f_�q���tck�c-;�%6���^H1Q6׈>qJx/w)��;�� *�k��h-��G~PAH�g�a��߄DD����"![D؄�M����:?=�s�Xj�[��u$�����Zb�4	��1>HrY�LR��SJ���x�3�ʛ���]s��l�����!����d��Q�C������ �6�7a醰��nϔ\G�, dfa���|Ⱥ���e�Bh�l:��
��I����=a��oJ�G�$��GM��tB�i�M�1O�,�.��(���	O�ȠN�¼��>�,����@R^U��Y<\���~ڠta����3�V���A߼'�t)\b�klZ	u���K����e�IVfE��V��U�F/�T\ս�]�}��<��ȇS�M�9o�M�(K�(��9���꼬H"��:n�ԏ��>��l�D^&��?���@?�4�/j4�3�yf�C���\��@���L��|�s�S��*<b�~[-�5�X�����2��;�F�Q d�6�Z���k��g�
��rw۱ͤ�^̬�! ��!kv���3YV\���6I┨�"�ֈ�{���\Y%hNUx�(���ۺ��4��
�Q�s^5��+��Rn]�K{-��̳�ߴ�"�3B-"U�l�j0O3��`
��m�� e����,�B>�Ł��r���QR�$�D�/�ze���r�n4՝�x��:o�)���J�J�����+I��Q�OK��Av����v��K��D��K���ී�6������a�KFZ���k��e4K��.]�Ξ�'���G,x��ʛ@T���@�;yu���<gm]�C����"�������ʒc���|���զAs ^�V�x�A]쎹���B"��"��x���nw��<��(�h�o�z�ܤ�D�J��8B�"3���)9�ϔ�U���̯�� ^�v��N��6��|�LͬH�2oF�LsC�#k��S{U��|�2�K[�(���'���8��c�o���c.�{	�'�����A,��0�_���t���>�?�K<��f&8���e+퍽�`-tNk��pi|l��ɰ#!����]aO�-�w E�
��(ɱy7���y�[,i��Xh�^-��x36����WӲ��G�ٵ8>z�@����p��qZ��� �(��I粼_R��#::���ۇOy:,��a�����X�#9�^�R��<����0�2������S��^��2&5B=d��pͩ�$yɠ�Q6�x	
Q���K��z��5Am�u��%<�]s�Ut�$�&������P�[����:�p|��+�<��� �hP1�,Re���]��ƽ��<�$9	��MHE�*k�9�;�2q�t��vg����U�T)ԛ�"����Si��˺�o�p�j_L��}���c�Ec��6�."!�H��՝����ݩ�>/TnB!�C-"������ļ^�6$��g��j\�,lKM���E�]�"`qo6���[�54��:���i��C��͏dm=�ͯ�moI���6�6�    ��X��-&������k��нcW��"A�e����H�?�/# g�ŨsW���%H�
ES@:e�MR�s\X�VÅS�1���T]6�r�T<Cw�z^��E��ɒ4.[Y}�Iz�3�`/��"�ܿX��;�i���A��a�!RpipI���/t4�v�O.Ӕ$*}� ���|�U����n뀚�0�=���*2iV��^OI�L+�CqǬ��~,�����QY��Tt�j�	m��U�kF����ik�;��n���V�+�
 �}�rD��`&��|Fv�~�$,�5v��o�������f4� �����6�"Q�5 ��0�*gw#7�]��S �*<�R��}CO,ʃ-�z� �t�$�|+�#]t�i2�b�3Lx�h�t���.��[��Ճ�A������=�V:�<nu2x�=P?���Q~�&�1�(�i�p����� �����Y$#�4���(sYQwfYQ�]K��ST�%p�?Hh�[�E��(=^*$�9ǩ>5���縀���ϴ���ia��o�ë`��$���c�����\�BQ����0�XB�r^��b�Y�c�J;���v����V^�A���S�.%�=���w\���hYa-KDAjs1��v�&�[A&$�o�O�-�0=�q��l^�^�3Pؾx/�;1��>ڋ�%.�A�p�3�e4\��W8�A�&�$%5jj'�[Oe��P������v�_��c�G(�C?�F�݈uR)��
��&�nG���d���)Uo�-���$����r(�q��c���c��f��+�[o��Kf�9Y����P�B��0����Q�����6]��e~��%�͚>�
��Ka��0�B^R8��[Ht*�jltȁ��e>'|�آ̍|�(ȇ=�3;�w�C���,����w-��
QO���m�N��S9�9_)�+��a=��A]oCd ���1��h9gM�������d\���3j�*�Y��%����`-�2��
Rj��-��u� K��ކ%k�uoj�>��-B�<V�EJ��g� `�1(L�,M��r	�k�DJw���@	�_�0�vq��z<]z]8A�sG��u|	-��~�. Ӿ��̌�<��w� !��@��er�,������������Y}ݙ �8Ύ����]�,��9�����:ۍ"J���.9m��o�D�#,�ر�%���ed3���F#
,q|i�7����X�
�̴�@N��[B��!�����f��"jɥ�ګ��ɢZ7�aP��r2K���v��t���~�l����q2���
����˝� ��k�^B��q���T��!�;�ݎ�2�߅�
����2%	���5�￻��8��� 	YD�@��of�����!���풷fI{�U�{2ax���I���#�5]lH|#�����XS �Ž��i�'
1�Ȇ��0�y��Ml���{P۰Gr��t�*��)|)�F�QU'�?	��5-�����[�v<;�F�sk`}��_d�t�yG�� �Y�avHì��������-A;���ƅ�2��/<�z|��4oxe!V�θ���bR��(#��e:�����1E�K����U���zm�֪r�&����n��1��6��S���#H�A���O�������6&��%�F��I�I�m�D +]����ݴ7���O��C��ʆ4��|V�`#��=�zb��j��]<D�b��U�Nj,6a����0_�T��!b�&|��xJ5W:�����PR�y�*�J ���
4ʠ^�0%��0�"��M&��@C����Oc<@��M���B��5q�����"��N�i6~��5ՙ��^�;VuM�jpH��&k ��BJ�q��UV�G�Ԡ�T�� ��ࣣ�b��l��A8a�ѻ������O�]�zD	��x^E�ա�rK��B��b�)�{GT^L~r�*�.AV"��B����L#W�~�N
�a[�.p��A"E	\XTdF��d�9:kH��j�p^�|)?��K��"�98%�$���ٝ8"T���Ԭ�������Y�|�WU)n���iw���e�V��.P!��|d�k�RD,�*�(K��V�*�S�r�	v�B���� � �z�%�A�H��,�Ж�B���qR�P�+�~��C4H>��IR^��4 �<�]�!�T�?�+����;_�-��=�Ý�v/tk�7wy�!�}< �f��y��R�h<B-l���a�:sP���Z 1��b���4v�E��CR1L�
�m��,�p����Gx�Q��5i/�U�a;˄�F����d�ڪ���́��d�h��ۂXV�QBm�P�|A�p��	mr>�xQq�x��'�[ RP���^����!�U���B*�e9ղX��V%�~m�̮�B��'z�B1T�$�A�gP�iw�U� �����$x_q����s�� ��+Rʪ�4���r[�01ڔ(:� p��<�i��w"�S�/z��cf���y���:�٠U��t�|��'a�	�`ࢥ��f�֚k.�C���<����AWj�m�Wj��+�yb�:�����r_"٪���=�'reG�0[c�p�G�D�bl(��Oe��� *\G��'�,4���,̉����;��+�!{�X�X���bt_U�2j��*֕�1�
a퐁�@�'v\G=���?!��w|��,�W�MB�I��N]�X�v�߳�cUAR5�%��
lu����3]�[�l)�`�Zֲv�҆��5��	����Z!�,���AՇ4lU���LP)�%Eڎ�����v,��g��=�ج�X�E�p����[B.˽8餡>JG�Q���/���7�Ơ��z6^"¨"�n��@"��"g����y��;cU�ͳ��a&-��^���"jP�|`fC̥�:����l�b*ؗ�T�u�(T���m' ds���/\��cC�����>��DT?rg<��DsO�\�GE>X��j�X^W3[��jc3��/�N��s��M�Ω��Ƀ�a��T�8��C��t|��3�F�ZbzrP@�b��m�71F�?�[�|_�wA��xQߓ�:G��ܫ��L�����H�k���P)S��Õ�� �C#x�76�!������95�x5jٿc�6T+`; $5��ԃA<��à���"@����n���;����^�MK,DR�8���g6�Z�Պ�ܬU�cDXn�k0œ+���O$,˜go$��\"J�
	F���uƶ�=��>��E����ȇ6�<�Y��l��xQ���i���Ds���R(��3�,�C7(d��%u�W�i����Fca�F)��!�ب�ÖË|�A���x�L �nkWAv��t;J�m#K�+ˏ>d/|�[4do���pٲ�>1�n�<mdU�C]��wv��n�p*@��o�XnW]��Z����am��g��=x)q�&�A�kǨ�Q��<C5Ɋ��B�hAC��J�ۻ�"v*�ۻ��2{��"��27@T{b����|6ЗŇ\��,M����C1��a���u��
��5B0�~��h�d��n������Ro2�M)�O2 ���#G�3h�mKK�5L���RM�mHy�Ps��
]�#:8���ˡ����V�H�`�GnԮ��F �����i�h翠ӭ�X���/�A�0�Y��vd�f����L�@㊟<b5���D3d�����t�B8sT���J�^b���sH�qJ�h��V>�/���[Okl�b��R0���Ok�YZ4�i�=��B�k�խ�*�A�� �Efd��;���FӺx��t�22��e[�!0��E�=�'��j�v7��\�!����")�����P����p��2�$�u9�GoE� n�2�N���CQ���ǹ\ y��潘i�K��8@;�	�m��`������=ET��p\h���h��_��P�;R<�FUp�'�Ha��ן�(��=����Q��l��,�l��I��m��F�>��֑o%+�HcMh�H��N��6j�P��:mvEL\Ak��Nŉ��&���� 	  ��;Ě~ ��ŗ��OH����v��>���x�M Y�Tț�,v�B�5XnJ�EL`� ��`	�Fm��)iOj�Ԃ-�|����6����C��cf6줥&ˉ���}���Ig|[\�4#z�̯������; *�[a�A�!�D�C�+�+]���핿��;�U�%;���K~VS{�o�S��$�'XTf�]fb&���U��7�E��6�[(�@X�6�_XI�k%�v�:��`�h���m&��������E�҈c�R���xK}�H�X��~	hU�o;}7�����?�������x1����Pl�
�D�!z���s���!�Uv�����I�w�xx_T�۪V�Z���0s=@��ն��;K^I[�a�0=ꄭ�!���r]�>`1K�!��{��ܗ���d)#���7mGT&��$��)���r�̗ȸ��5����/���=�-{�MO�SH���b%���[��el����֟2\kSkT�t�){�Rt�Iq�ܥS�+t�Rn�����Y;Իh;�ϞSy6�wi"І������ߎݬ��N*�/	�2,[[<�|�JI3z�T����p���jÂ�Y(��[6���i�gQ���W�uf�6�>�	��.H@����j�@X�i�(G�� n�UX��B�H��/=���տ��t�qAb,��J�d�'�\��rgٯ��RYt�E�)Sa�$M�����U{�{d�^�A�6�/�z�JB�UFu7��YW_ʮv0��?��nt,����D�:[w��:	v�F��9p��9?�;��p��l�&��Y*?�?������[�U�&.v��b��Φ�������I��:6gN�F�[�W/o�N}.��*�����hW�ҳ���E���|y�6�����~;�9�9�t`h���0M30�I�.K��/k�`�n6K��!��O��x�^ٯl@Q��x����1��$՚���&v���x̵ۡ�]�ZE���Z`*Y�����Q#3���r���,�~�d9D9J+Bo^Y�-ݹvo�#q�� ~������k69�g����<t�d#h����9��1�>ې&��p<t<���dյ2��,�ĭF.}��4�we0�n��ť��ع@��b�eU�7��W�Y�њ�B��AĖfo�Y1O�މ%��|�Ǹ�?��NH,�)��5Eǯ6����ш�cV$CT�;�0�:������c^�m�ІA��I�(`Ɨob[�����Fۄ�����.�w��+�QЈF��[6	!=��d���~���z�	���e =��زW�0�S����_5�ܑ'5��$*�[���rakD�d` �A`��/�3B��7m}�|��{�z��φ���$��I<��p�QUF�L_G: �&��1m1�z��z��k��D岤�F�<I��X����S`�rї��Œ�O,l��=�/(#41��X3�K���e�eQ���x�ϤJ]a<9�#��ir%��}d�� !�h
��[��咹�����"29���N,6i��i�-B+]ԑ�@�hw툉�����(P��mz,@h�v���$�8�<�����zo�:`	��p��WQ�6����(5�	(4�?��U���cw�D�I<X�#R�*P��,C=e�W�X����"��^ӡ��~�� Aj�v�[Z����|J�
ۓkU@~|�[��H�n����'�;�c�n𑙖4�vx�1ШXQϵ����d[�E�1��ϝ!γ|iN�4;�u������@Gc4��R������v�J7�Y�C��*�t}���FP����Z!V�/��M�Z,,*Yr_�1�(M���9�'�qr�D>{@�����iQ�yo<\k(�ی���Σq���Y�X��Tt�@����N���RUU��7�x[��];ϝ��'�{���I�`6���A�Ʌvt&A��1
��	(�'�k�V<��M�����x���sE\�Vye�5�k*�$���� C�VSH)c���<5�.?&j������j�*^t���N��z���LG䗢ݠ8��{	G�>�t�\�WSMؒ~ۙ��Fód�V��N��`r��M��Pp��K]��\��*���4�h��6�!]24�o'��F�F��΢M�ٲ֏�>�6�>R�m�h؍ޜ(��;Fkl�)|]�n>>�#6�Ax9�^��2�4���mf<x#�N���n�kL?��`d��,Rt9����d�n� ?w.#�n|w��D����������ڂ�9      x      x���In&����N�x��L.5�*�R�axi�����Y�h}��L�I>���,��ֿZ?&��w'z��A�ìʏ6�������D{sbU��N�>��������������M�_~z8{?�~�bʏ*��=Qs��ߞ;}�t�p���SX2s�Q�h�5G<���W�J��Ȓ��/�t$��;�����9���Q��c��L�Q��2'><M��N��]����t���<yO��Β/���k��\�:��8�Y4�ر�%�co��F2��<�`O�a?I��)��O�홂����H�T��S<?;,+�~ԅgf�����8uX֚<v;K�<Mn�Ӈɟ?���u�$3�퓮B���^�?h֙�jG!�k�����i�w}�v+�� 	�z�q���BI��>�Z�b�;\__�F�y�'���!s������4���,~��g^�,#������8(�\������r�ܿ(˂�W9��H�bGέT"��������׃�:�ƑuW&i��_Qk�0�cRg����iy��I(�*���N�G	X)��;kr5��W*�լ�������Ǭ4g'i�U
˿�2a��D�ڜ||��iW�fE�OF���ڷ?Ta �+�,�OSԧ�U��!/������r0�L���Y�Q'��L�w�,,��ο��DR��w��y�:M,�=)�V��ф���B2��x硿�b�{1���O�f*��M�HjN��d�����i��7��(E��/�LV�S5��;r�ɲ��A���2��=�g�5�����c>Y�y��Ҥf�}�W�/G���G��o�w��ꎕ#�U���R�Y��?+�Vxpdx^<_�Q@��O��t~��˄X5�b9�sM������.��y���Q�@�x{姟�S5����3���^scŻ���V'@�]F�jKu�]xȜ}>O:�>����]��z-�:sB�,o�r�&׳:ZJ���{ZE&��n�h��a���RK�\�x�lC��Џ�ԨɺYe:<7w������}vr^-[��C��j��R�_�Ȼ�n�S�:�J�Q����t�a�=WG_鑛7����4��2���J����$�rY��a*�ke�/��7����#���ts2�4�^]f2�Z&�Yw�I�����q>M�|��V^�:����_q�wʉ��zŬJ���jQ�|$}?E�eA���͙b��Z�Y�����T��=9X�Q#e�볋L�gb�lF��9�e�A��p�����!�����cMN�<������p�[���Wu;c�����>���Ύ����+�#j�/^�l�m&��`˟��٣��5�T�=G�G�Yz�3��4�{޷ ��u�΁�X޷�x2x�cYNV3y���@hb��G��$[IH	��4��S��_
�6$Z/�z�2#ONiV���Kv-�����'o�Ȩ��@X�O���<�?��d2��!�T�dþy������f2|�"�ѐʤʴ��'�!��7rn�dN�Y��ݐ/�Kɳ�[:^9>cY�����������.+�t��X��*�r`{�D������=���[ǫd8M��|�h:�P���Weֱ��;�8��gH�:x��O��4�w-�I�քC	-9y���Y"������͐�I��hN��=���#�T�{���-�'u�x�8=�<#{|�n>G_�Y�{h��t"�4��kL���1<��E9���Z�i���3C9Q㚇Vz7#��K�W�\8�3�~�jU�C���:��� T���j�,�w�����R��wc���斷p�}h�k�m0@B��3��	 ��&�r�[�Vm ���+����'�I<�z@�1�}��7 �&3�u���5��6�&�S�S�/�<�Clg&\L=�����)H`�|3Hx{p^C�$���խ��<H,��kL��#`y���.��q������ �=u;i��y0�*߫�Yv��{�b�qI#���� z:��U��ɥ�,6���<�K�m[2p�5]�I���R���<��{���!�n���$
�_�,6���*ь�&�Ы =���2��=����8d��t����7��谗�Y��A��q=�ē�!h� {����v�`�j��Q`o#����4(jr�A�8H$����lo�U
�s#W��w!��<�VMj�#V��A��Zs:z�mLD_{���G��^�VG��i(��FEZ ��	҆d������R���A�1�po�J��8��j﵀�A< �u������(��%p���Q'̓{�)�P>�[���=�<]b9���l��U#��N��,M����c��^�6�Κ��h�KxIob�7��F]�,�Ͱ�@{��L��bt��5i"��6%3�]G�(��И y6�p�����C���8G:#D���t��t�yl��Ud�ҩ%Q�ϟ�S��S̓{(�%!����դ�?�pó,gp+3���o��ϳ��y���.:�����Tf��ǉ{%R���v���S��6�����?���=�3�]ݜ?�d�և��;���^7V*��Jg���~����}�W���_�o�`���(�>��e���'�t������-̄t�J�	N�Ls9���Kx��?ߓ���>�c����Du�[}�/F�+���/O/�z����/�ۉleiTq�_��6�o� ~#7.叾�u����ǋ�L��륬��h�R��nM���	J����F);��符7���b-�ᙱi��Q����2��մ������y���Q?Z�&����/Ӈ�jq��1�ς�t��eϷxS<��FWA��N�"���@�O�u׷�6������+�T�t��b�6S�zz��1��R��s������d�?,1�ހ{�|�w�Wً̄X���c��܋i$�[fjQZ%��;]e^@�����5��t��<��9bU�8�Z<�u"��jeݯgX6�*����
?k����ϑ�J3�]��j^���Ө�nz�n�詆ޫ�6�U�p��E���a�	�uʚ�|��8*�9��)���D���įD}�9��(_>��<Hݼ��8���O5�"GGT��|80 ��a��!Cva>�'?gV�@���⮽9P�ò���QT-�]����f�9��m9����j�U� z����@�,��{^���/��*ɤ�)^)�\��5��<8D�3�
|�O��=L%���@�̇�k�{�u�*({B3�'׬/��ܤLz�f���P I�Faz!�j���Wu���G �ӝD5�����!A�1�&z�Hp���*ǂ��5*ל�´�4b|]粔� f_J����Pģ)�㱇�}Mv$b�y\P��G+f��n�6��&T���u4G��@��1�h�y�n��G�~�h�2'�l����y�4�^F�Գ��d�GJº}�y{�B���]�M�Ds7�k}���!�����e�x��a���1Ν�.S�
��ʵI�#�K��8�{�_l#t��H�t��Z���H�B���g`x�P�[J�x���q�RY}��`�����>����ЌKoy}ֿ��i�� ��A\�Q�{ u��Rf��P��a���g�A����f�ʗ���<J�h9��w"��V�4�J^��_x�c�A!T"�긚\8f)Je-�Wd6p�&w�/M+����8���
�rt5@�G�F5y7Cb�53�p�A����EϳF�F��7d����&�1@�����XS���u$\`�h�Лl�J��	!7��U4��*�
�{�atqz}~<5BW 	�J�`Vo��}��u���H���K�ȋ#4�x��ѩ��W
�5+`x�3�S�f`��-;��	jWK_��8��H��]��&��7#��#D�}�k�����PC� �0D�V����7��rt� �1���-�!\����CR��!�ff�웝=_f:<Okd�R��'���f�n�Y��社ي�A�Pg�����[iQ�1Mޔ�=�؝1	���<M�[�v���G�9+� Q��������%����\>    �Mz&I�&�xH5vg�M���;1t�#`�A؄?%wb6�!s�e~�kIr��
b��k��*�4�h��#����Z�e�T9��8Z����C�}
�
I��33<r���"0�	�����C��7�?<���:���Dk"�A�k���8hl�eS#�Zy]�%^�$�Ƣ���y�c<v��^���ek"���3�0��x���b�l"%j�l�n��2O𚞩0�p��W��X��`�����IZ�`Z����!f�"F�f�;��) �Ԩ:�4hiV^ �}%"?�5��#�h̓��ӊ���6:�T�\S���q�[�[-�r���l�Í�7ul"o�4���Cڗ�G\�n�Í�A
͂��2|�Њ��Sޢ���&� ��Ի�h���C���4�:��V�`�NB����#	�ff2� ��D@Oĳ5<�Ƽ��v6M�7-3<>Q��n ��yt��$nZ7�XO�D
����g������,��Wt�X	�� ����)%�	��ip���N4��e�OzK�d!���'%��i�y�j����K�g#d�t�������w"B������DBG���8e��i�Q>�R����!��Lho��Z�Q	�Ywu3����)��� ����&j������;���2:�=[�Fo���Ӑ��kz`�0C�>��ɻ�d�� �t�M/������,��sBK�56:Y�I�>\��#�</����:[�,b|�!:z%���=��1]D�1�tVۺ҉$��~=�Pl�d��y�[��MS!k7����ka��
�!*�%3]�}g:�����9��������!��I�����O�ûԴs� .��)�糟L��҆Go�/×�⚗�<�1�p{�pj�^C�~}�\e�ҹx���2��t��Vc`����2e�*`�T���,�
�n.�3��I���p��:��<�f��#����Iq���O��9��z!�}l����)[U��δG:K=���mH�]w�Í��*?�3@A�S{�����~��+�DZU��|á��D]u�Y�g�_����w�>�2^L��~�� �L)Ղ��;�����]�ëhH��0A6�7>�o2A�I���%0M���	�<�H��O���|���u�T9���~��=�9���C��N8��w?�o�lU&�;���MT�������8��dO�jݘ�n�,�{H�R$��j�-�|���8E{}3M�5B��H�Ԓlt�a�����bV�l�F��E�ts�OF߾��� �¬�H�i<����ҹ�GPY�L1�BhA��o�C�,���Vsr�~��|y��2�P��3��J�Oz�J�a��r����b���L�W�t
���4�TӴ��E�Q��^^��1���ܳ5�_oYG�E�<�Ny��ЫCV��=�[42�(�k�j�	�4�a���y��{x����y���lfD<�̻����n�w<��H9z��V3/��3aK%޴����T��!)�Z�3קW�� ����L�ɬ4��p�^��Yw�Fi㘝%�'��=w~����V��
�G�^fҭW	�<�]����:�����G1�2�Z*>di.'� "�jf����d<SS�h�ua�A��D�4]�c��3�^9�}Hx�ۯѡ�@��������n���&�� �Ǭ�� �����>^�`���!�</d��4���>����ݞl4�D��ph�줡�B�H��݇��/��e����@��צ}��!��̜�'k"�n0�@Bf�9W�eL?J!%h!q��}Ϋ��ϿMMkw:����d�N^���R�ĂA����׻�C�h �h--'ld�#���i������  �����i���A�|  nl�̟�Lhw�9m��~'�~H��e �=���#��d�z�5gfy�u�����Ti��<x8�I�/PM�\�vȥJ-��խ�^���66�wғ�����L�:ye���t����P�4����Y�t�������[���5�rA<?�MI�Z�Uq�d`KQ�݇c�����q4M�C�9��'K-�8 ����Lެ�*b�_��y_����R~v����Ѫ[����I��T2���1��G��x��^�'3]��!f8�R� G���6���3�U4���*�d �V@�h?# �M����:��S?� ����*tB�� A���!�@UK�8"��L��á�L�̬{��o:Z꺛9�Ă�)Ra� �8?�mo^��k�L`רT�H��6�#M-��j�^�pR[*�蘓��t����F <�"�] <Za8)p��/F?�E��tR���#�)=�z�W��]�NJW�9x0�4N C����0$p:���7�Hq��n�Л�ѝ7X���@�J��|�;�K.R�<�n����@���fG�I:1$U��@.'�#B�AGw��< P�;�G�o:�Ĕ�͔+!��\9�	M��d��-N���{;aN)���"�Mh�e��i�J/���28�6��F65z0ͫ����![.3��DY24���.��Z���!]�I�1�ڜ���0 ~=rcӯNh;�[���ow[?�t���j��0��!����N�+&�x���C=��~����&��jX��w����Pr�p�fW�+�w̐s��o�rR',�^{/��{���K�4{��$5�+�섞��b���,q�j4��;Sm�Z?�V��A��1C::JY�3(��Y�<F�c]{{w��vѪVh��*4h�	Ki�YV��?a��(�<�g�tv'��:2y��h�cH���e���MP�`p����C���E����ִB�S*IF{���ǩ�@���>n�t��N~��W1ڍmMpUB�K���I���_Df8���ٖ���h���^q�����)f��H�TE�r�ǧ�)���vg�>�󐴔��=ͩ|�^h�<(�埇��)�l��Y�w\���a��|�t���n��$��3�\_O��Y�y��⇍�]gD/$ۈ���D���	U����L��)��'t��Ou���!?�����������LI_9Z@IW��/��˟��Fe�I���lt�\}NJ�,<X��ZM�=��
^C.(�?����ި�E����{���^���aU����T�%�t��{{Y4BaX)�AK.�1�%6��;A�;]��U2Uf?��9p3:S�C�;�Z/�>�������B|2_���V�>ه�6e+�7b���^Y��3����.��	h���Zzz9�&O����K���P��.:ǒd^�7����/�@a�gߓ���vK�=�ؘ0;���\�$��$������yn�#�*��^WB##6���*�i�sB$��;ҩ-�3�tY�0��P�o\v��dY��+V�� �������.h��������
%	�R~��+���3xǴ�ĝ:��<ز��	}����������ʻB�o5�su��*��y��u;�X%��u4�ڻ�+4�A�w?�ٳ-V���Uk=`o�s�.b�4�.��F>b8#+.�ڗ��hm��������J�!z��y�ps�@Ag7>��b{MY���HT����d��������W���E��e:����}�á;Gha�!}���f��.�°R�o����Q�5#&4?H�����aCZ��6s�ǜ�>�b,tv�X��F�ާ�/ʇ��it��h}Z0&L+�tk�0�߃p6�FL[˳�<b�����P=`CZ.\�C�|3><jHkg���dt-�B���3���1)>*��a�}��"#_ո��1�l��L�=��e@i�v����=�����N}����W�wYi�3J�U�I�Wl@����c�m�L	5G�G�k�Jct8�(�;ɺd1JE:,3�;�]n�S�̅�ҡ���(�kL���C�u�����{2*��L�_��h�>�`�q~����D� xB������sJ�Á~����ќ��zv���w���<b�Ee��W����������p���r0�D=��y�Շ��|�z�u�י�F�2.�    ZS&�����ֲ2�4�f2<��%��P���t5�`z~N)-\�YNK�n{���C����zM�xa�!]`;Cr��{� j�`	2/�n�>��I~\Y-pt7@^�S
m'�N������#�؁��"n�j�<��;�#�7��&�fQ���pu����0^�!�C���E~�!�z��Fx�vx5��\��o��H�,����B�_y��#�plz����QC�t�s��}3�c�t�.���5���[��N=b����y�ii3���6�C�g	�!Y����Zk��)��$>�_�l��ސ.#홗Q,�x�C���i������{2D������<4�9>���_ZW���f���txf6�#���Ǵ��f��m�4KU����<b���� >����^�nH��z-��B,G� �А��)�������h�#$��e�<�cH�����z����)��Y�jA)o�ù�צ<�C���($�Q\�Y/l8:=bt��x�pؤ�#����=�4��[#'j�� BɁELl��L�?�T�v��iV^�Cȸ�FxB�~J���@�tWqJ�q/����#;<��U�9r/tz�F�=ESK���@�%�9�B�+)���X:�AX|	DS��p,�(�-��̄�`Y��} f�P��`��A�n�ay/�4y���M��8$�`9O�z����1�<F��b1��p�<��N��Q���	�<

�I��␎g*ş��Icph���oN��␶K�FǗ�K���q~<:<C�+�[錹�?.9��7�(E_�׬�z C8�c֙�Y����/�̑�*�9i�:��p9�ʄx�Ñ��y=��	ٔ��c���7�y#�J���pxz&���H*z����b��u?�B���t����O/�Y�	�!�Y�&��&���_�T�;��䁹�~�l��j�<���Ge��&�e��eR{����w�	3�����
�!m��pב�Υ[l.� ?m�c��x�L�D~�!m�YV�q�V�����>��ׅ��%q�tʙ��[�Z�8�빣�Wm��x����3��u�C����U��)4�V/�OF�G{9ęc��W�ߥ�f���)�l�%���6�|wU�����`uV��+Q��u?�6��іI..��L7vH�pEA�fF|�B�RYV��C�E6�Ήa��p�C<��hPԆt�gw�����	_f����.yZ2��-����k��*��>��C�͠0�#���|��%1$�)%a�F��z�}Z�5BD�~���7 ���$8ۑ��g:�3g:�chR�<���$�\ݪ�C��ؠ~�������*������"Z6�"�º�V��6�_���7�y ��5�qs��ˈ�F���3��~<.�d5B��G+Z�JD6�(�X*XӼ���*V�h0��K!�u�u�@j��d�=���.i��4�De�����!��<�4�ń���C�V�q*��gAXuF��:���>�x�B��yYQ��&fY���-FQ4�M-
"i6]�Rw�AS}��C��k�h
l���|�MڧL��gK���&������h����loX9��:�u�V�w�DaT)5���v6B���M�	��?��RP%E��_���YDaT)�|���m��[1B�j̍�pA��\�Ґg���d�J�9\J'9:�]��C��!�AJB�tE�產*�`�G�j��xz��N�ʃ��ʛk�bs��Y}���)V4xͫ��
��R�����6�lPJ:���8��)�n7=��j��!�t��V@e(8j�ـ���׌�8��,=�9[,D�z�c��Èô-sc2f�{��	�53߸h�8���(��R�R�jA�-������#^�޲�eұnHu�^��D뺈�7��r����P M=�~�b�Y��1���گ�� t��zT7���  �`�#hS_�zC<����c��*i�M\U� #w��g������c��S�&�H��f��(�o@����i��o��$[�����Bx(��T�/7�F���3
X"��m��gЂ�%�9�ăXg���&;�¸R�.����;L�䂌���W�D�Z�5�-N$%�-Z��.g�E\�&����PvR�?e�o
p"HG:Xa�!�$3޹Ѕ�(Պ-�`P�g�"�8����[S�<��m .���v ���|�����Є*�����(6�����"�!}�8{�H
{~`{=-�4��*jW�ih�Mĺ�8 J4n�(�-5䪬����"?�t���!%L���5p"U�Z�7�����ar����:M4�e����C�R(��R�a��E�[7���R�W�Ñ���DȾ�
�u0���|�lg��FK�<JB�!��!���0�F�zz-1ȣ�Ð#MqBV�x�k�K-�pZ�|�'"��ɑG��	x"����,|͙WŸۇ��Ҽ�BVGXwPY��п��8��j(Ԓ���);~��*�c����a�VCƵ5���r�B(F�����X���D��}�D:��;���^�>
P"�2��;��^qf�y܊eUԬ�F#
�iC�:�1���3A�-ݜ���ȷ!biE�{��eu"?�;��E�����y���5C��U�G�����C>�2s� �L��Ҵ%�����=J�AAq�tD���\�l��g�K�!>PU�/c"K�B>�'k3/��>�e�r%��N����O� B�!��7}��䟾3��BS_�D�/#�T'�]�_.��a�p�}�	��Y�[��6��]�63��"����RYN4���J�L��-~��-�>�:y~�:�lDF��q���@�xX������(t"B���:���C��?�O�`S&ć���[jt!zE��w���%	��3>���i�M�,7k�EM�`J���!���*!<���0T�}��Im^�2>�1#��z4v$W�f3�|:���V4�}U!��Yʄ���. 2ˌ�����>�{&��0^��K�(;�s��W��H�-&Z�hM�����b��DB�����JV�`
��X��(YZ䷊� &��=��c~N���5j<n���I�K�	�~��c��r�j3%��x:�����e��G�LoZV�����$�#�Ljo��2���5�Ym�>��!Sڭ:��hW��;��z�c���6.O�������*4$j�˳��5�+"�+|�3B��X���:ґh�iV��˲��i�6���V�N$1�<����<�]�O�Uۮ��`��k���DC-���;�ٛG�-9��k%���{i~i�a�-��7_B~�)VE΃��{�lq�)}��kZ �|J���k֕����:t�\�Dk�Ǳ����.���l���D�#!��ԥ�A�2�$l�$y��-�?s�&4)�ٯu�g��M���j��nuم�t��w��zo/�gB�j;�r�fr�b�_@I����%(�������qbf��<��� s�� �N_O&�n��W���Zru���Úi�N����FS����g��H��ӡĠEr��l�ZD2�w��mw�p�|r�t�-�V@�̣������
�� g����[Cp+ �_q�wm�x@���Ka���$�;5x��n]ܣ���F�t�/�L[s y��v�.�n����		k��$�|�c�h�T�e%��͏��ơ��H�-[m�Sf%jFrn,_c��iX��o]���r�N���6h�&��R!_�n��\�q��#_�!�v���c�$.2=H�FM>-Jn��a�i"ץ1�"YHoD3k�$!K�EؕHw�������!�rC�2��~�+�a�)�-%�F�E
�O�fʥ�D�F��&,L�Qtة�����1��ݚͣ5O���fn�En"�U�Fj�UE�[~u$����&��6?u�� �j��� ;��"l�?�Vmx\KYW��Z?'�ZF!0�"����$��7⇭�(	sPa�Ɍ��9)c�⟄ŉP�Q&"�i��M|#��=��#p�*jI�a��!g;�%l��$t1    B�������R�!H��s�s��U!%a*��H��F��I[�i�f�/��X�qHؒ������$~���$��hcJab �S̢;S
�d!�2G�&	I��)�[��IX�8����~�{d1#	ՑW�_�68��h[�i�����a������C�[������QϮ6$�Ð���f����8,X
${Ȥ!Bbi`)�A�ՃHB;#���2�FH
�?�,W��gjqH&���q����]�rR�����d�fsF�0���/{t!�v�H��X�(�����F�@���H�WF�1�/�-Yl�3�I�"�4�ͦ�?5�؛і��%`���yb�G~lAVI�#�}Z�ե��5K���:jFM�"ɐ���7�?e�0}7���[W�N�q�=K��j���?2�(X]�LYBY�|O��\eJ���n����8��;;�^�>M<90w1GGB%�H�b���<���+�.�T�|y;ݼB�5Q�Y=h�wч�j�bE�D�����ɯ=~�IE3��5t����H�j��&��j�8�f�8l�%A��~&[����V����@ޮ�z��oeԡ-���i��������.�틬������[k�6OM���묷�Y�t��I������,	��y�l\��.I�Kj��;+U��J䎜r���L�_�i(�mI������F�U��ܔ��:����4 �dC-[�4��tN#�S�OзׯY�|�7a�"e oAx"%Mq�Rɠ�ż�O�R�z};ݚl�$�j^�ne|*���OU|��,��K#�I>©�ɩ|G��D.���h�/r(�O�#�h%���%ؤ&$��K�;>����8$f~tmz������;S�<?�즑x �c�:0Hp ��n?<f�&�:崸ۂjk���p��-���� "MG���nOD$��7;��O$��B���uF�H{ծl��Q@ ����.���h�	�:���P�m���5?<�b,jN�����ϔ�ʄvmm�b՚:���>�P>mwΤ���X��������g��!��F���	By?3�"�����#+^u|�n�R��x��t]`ӔQ����RD|��h�5���T��=�1�o���Ew�>.�e�u��/���xr�f���:�߼Ha���]65!�	8$��f�=TE�Z[^�W��]��fVu-"4=B�>d}�ƻ�d�т��Z%���J�,�� !G2<9Ա''�O�C^Ϧ��;�J����;�Fcm֎Bף#GRN�2����WQ�c��n�}���Y����K,i����>2���H�LK����j	�龎ƍ�U����,�����-q(?E�bG�>揋�w��F�U��V%�Dѿ��./O���Ҷu���!WVʔx�7�'b��R&���+�D;�Tj2��jޓ��n��gR�4�o�\R|I���B�pv6��T(�F-D1ogg�,�2����t��1�)����话�R:��2��g3I%��R qu�2����$�A�J�$eR��=��^����+eJ|�J)�A��μ#�i�Mw/� ���Y�o��+�H�G<AZh}�j���55�-X�5��)��	�Zy��]���̤v7څ�:��Pg�(M�q�}U*��̔v�R�:�Z�(W�I�sX)8���-@�΅/y@->]gp�����Nx:�EI�"�;D��.I*vI���+'��Z��Ѳ��N��/��v�Μ<\�L6,l�W�]�/� l��3�]��F�Nif��Ljw�����E�9@J8����cr!S�'P2�	� ��S�.�_̦i�A��b�y��s�a�l����J�u�� Ӛ�˔�j]�5�T(L �^njw��&I/5����d?O11�f3%���e�E��{�B�$]�Ѓ�o��ws�����8��uCL�'�u��V���"�ٯLiw0I�-����xВ�������;�AKTw�v*�ꮻ+�r�3�
T	�eM�eJ��&����
n��~CV��b,!��]�����I<`�PKO(%�'E<(PB�$�ۭ�Ư�n\b-MyG#\�FJ|Vb����'��y��N����د�*��r�2���e�������$��cN���.�	S��H9.ߑ"��dJ{���)2Z��WaN+Pҵ�L8S�3x�NsB�S����fJ�`�y�P�x�LPE��fJZ.j��X��Ƀ��+O[ٸ o����d�:iJH���j�cn�DD��~M�f:��B&� @/g؄��4.���r'm��؄�N��n�L���uf� ��o+܀�1�UL��fR|�I��eM���<�I��ј�Xf���~J��'^��ߪ����)���1XG�&S�K�N˱F)Ǌ�0��.��DnH�w�+�p5��!1����S�+X�VبY�5�ń��V4��p�a���Qw��&f|��>����/P��4��vJT��&i�W5D�����!QSj�c�S�*�&��O_�n
)���Ut������J�w[H�N2����"�>�jw�|�����@"�ʸ�wS����!��n�v(K�ׇi���I�`'zӡh������S�/���4%��j��e��|:XW�v��$�<����d�\J{�;�?��~�9���2e�S(�M�_8L�4J���t�P�|���m�|��{�!�0?R�S揓�ڡ�Y���r�(�g!���+�l�qw~pnў�	>������L�i�^�'r���^�3T`�S�����R��W�-�6(�4B�qv���]��gi�&I�%���)[�B�W�\��U��9�y<˿
���kF��4��0���ݟBi��xɻkQ�����-_���k��]�3�����i��[H�֫Î�x��y���Ҟ㢏�+ĺ��!O��k��ǻ}���J��Ŷ�����U_��^M�'�S�+�pO����3�sR<���I�z���Ձ�a�aq^����e��R<�ؙ��ٛ*{�/���
%���	+�| �bB=�Dg5p~=羚�"zB3&E����G�!?�|B{�ڗ��Q�PY��^�}%̅��S�����4��]ˍ��c�.X���(�%s�r|ޠ��'Y΄
x���)F3R���,QQa��s!�s8�wƚ.�F3�]�J�c>`
A�6u�s~��b�*<�I���.+r2�/��_�?Y��.��En���9�ܿJ,��b�_�X�8��N_�r&���/���/�,��I_N�˟w6]y_��J�=�����=u�s|0��~J��㠯I�xWt��XZ�����b���`O�*��L~����`O2nji�oz<�z���	�'=�u�L;��4�(�Gw4K��(��	���j�O�e�1�Ac��	��+(A��0��NXAI��.�M�n�zz�(�$ �d�2�A`�n(aV,�t�v�
:���0,��n������B��T2��񞨵k���4)�ek�=��9�K�'�S��ߚ��c��|8�c|���̓����zZ�a%���'~%����i��5�B�&I�('s&x���X,_)�ad�[a�$�P��W~]N���߭�9�"<Ɗ
��Яi��2�~����)A�0;�r�Q�>�����Ip�e]"��0���)!��*H%.��'ʞ�s�O�t��1ţ�X��*�,xv�Em`�Mj:�J��mR�Y3ZJh݄c-$���:����)a��f�k',�$��eͱ�7��?��4uy6?�K馁�>����M¥�>�����s�=�G���M�H_g0��O{)�L�B'�%-5��Ԡ�U	�'�*g��:��,��g�O�t:3Oo_���n��\g�
i�y�(����������v���/ER���ꢈ��NZ�f5\�P���t�ˡ���3���o��h���Ѱ_���%,Ǔ5������G@i���|I��~(a�,V(��p�?��t����C�0KW�*t��cփ��Z�Mz�G?��2�%W�Z�৪#�&���?1eS��(��Qm�ύ��1�5��y�?�~�ě�I2�ѓBM��    :�\�ݖ�u��bx�g��a�C�B����X���c���w�`��	�1y�c��4���n�n��Y�?�k�t��
g!GV>a1�C�Ò ��zu#`��o�Q�z-x��Cg��!��,�ހ�O*�u�B����=K{G��H>�B�Zo�O&|�[��Z�	�����:o����.�e缩;ͣ��aИ��+��^)�2��b�*�L��,��	�ϳ�X��'B��e��*ͣ��u���ӴP��h�铖0�C=�"�����O�o�ͮk~!&�g�I�m��Qwja-��FR5���?����и�[��B�S#��q���ZL2Jr�,m��6�帴��	IӹNbK %���Oں��蕵"-�~�Q A�Z02�J#c#�C��� ���CגP!1Ւ���LK�!�)KÕ��C(���QK��z�@Pj<"��P+���;2)3:e]^��OC�|��
�4�b"��N/�� S,�~�+w��k5���@i��
�(�-F�Z�w��($�|���d��$@�P.Pr�8sH�4�n�	?�JPj�o�3�r�P���OeD&�b'�}�|M��Or��������i�?�B����k��s�X"A�zfK�(�0�9�I�n�xt��$� M��I��,�3Y,
5��;AR�ףi�V��ythN/�e����:����.���àz�g�R�9�"����������a@�2^�x&���TD<g6H����9��e�����MI/����/�B�C�RF>}�}H��С�=��!��ob����}�4|<Ҷ�8�/���ԭA�����ɖ�����NS�p��A\>�l����	�,[�/�8�)De�3�Mm�˅�wy\�����r�����n�a�rM�K�t\yמ���l	���b��O�F�
�7n"���M���������`ʀw���O��X�W���!Ptʗ����)E��+��x��pf�l��/�c��@�0�eX��砣�]�t��J�Uic~��P�U
T��%baԬ�^����R}�o|4�jJf	��]�Cqۜ�9�u����x�{l��?8w�|x/����6�Vf���)�Z��9�GlA��`��{Q,�$�a�G!N����Sh�$mcK�� �����i����OW��7J�����)�]��7��찵Y�=�:�����AHZX�	��\S5�v$i���k2q!����Y�?i&
�F�w���?�3�y��������|�N/���[*�g��FP�B(�c��h	*�4����9ꃂ8t}��x?a�-$�65�����-i�{��	������)�U���_iI�l�ϪH��2��(E��/KRZ�AL�J�>n����@GA.��x�����A��.ǁ0g>�ك��8�<��gkQ�Mj�6�����O��f�:�3��jS��P��R���R`��]��N'u�����𧢗�%�T'�_��
;����P�"��`a�k.��4�%A��X��O,Ş�5���w&�J<���xQ#�n�����#�PH����+Sg�	�TcN��~b=�\�2��1�s�s5��J�YY#,�$)�e
����_nx�V�[��3T���0�F��u�-yR�#�.Y�N~�Oͳ3B�'Io����L�����OU�io�P���	���_�?��X�-x�-�dx�s�M�i�4���v~�bI�~���	]����9I������j���r����O��<)��2B�'MBi)yd��3<�j�B��Ȝ
���q�ˌ�Y����C2�>��'��̞�v��1���}?����U(�fX抚�Q����>��O$W�Jo���˝�'ҵ�CH����MQ(��6�:�Y��6|�'m�Sy��A?��.laO~�-��,���0v5R�sĪ�X
����
�-�CQ����z\���'�?�������/�����ʉ���M����s��\��ܸP��˲���jxؓ�r/���[������=�'>�'���u<�Ѿ�hS=o`6����5uf*��2����xҘ��#�.����G�ٌU��O�1�'6c8������j�X�DA����ϻ��=C����vF�{Ƹ�e���sH��J�'/�o�F�x�3�
���OS��	f^�'�Gh�-Q�~"����e�����
����ez���z����'v\���%����x�
�M@g/4���.�=����T�t<��C{��z$lԓ��^�-A?����?�	�݉�]W��sX�FX}������[̰̃�O�T<���TI)�NВ��ub\�j����Y�lFX�	�A$�eS��B��䠡T]l#eƚ���������oi�z���?&�0���X�==R-�RN�|�{n�긒�U�f�q~�-T�$7�4�4�I����*�n�����0���hN���>Ж(:F����s��	zEw��'�P��	�ы�0��=�׀�1Y׾�G=q4S�3X�y�'�D�L�G��f�e>I�	�4�ٶV�<��d�v�'������9d�]%�+(a�- T�.�a���7�(~�-�A�`j�2����C�.��o��|�'�D�zp<# �ta�0e\ra�-].I�5�=t���J��	�>?�J�u�R�Б<G��n�0%'�b�ʃ��䖕�h�'��%u�8�T�*nJ�)B�'��!���1!)L��S�er��5���c5Tq6&h@UK|��5�PG1f{FZX�I5�"M��;v#̹�,㔢�z�`�unT�'�w�����[=�E�bl����
��e��XC@;I��2�O�m�Ȍo�DW��5^l��
��I���Ƃ~(�����Ε�uϒ�2��F��'����U(og�*�S	uB�Be�𧛇C��BjKH�.�嶖QQ,���>� ����L?��h�Bgr�bS\�c���̷��z4Y�n��{B����,v����Ê��.����_Ȍ��t��1�,�E���i��nM�������y��S���jɆ*t�	d�s��� ,���E��/s�#�,�X�I�|:<C�b��t��4�^]f:�e�V6ljkR�_Fҩe�J�/k����Znh������˯B�ah�ݖ1�}�г�����|�'�q���*t~��U��8>���O\~���B��h��8���P������Y��i�Ae��w��y�*t�6�3%DY���h}rw�z�V�,=���4ҪX��]E���:(��t}V�L�L���0�>�����l����5�\u����r��: W/}����^O����a���\��W#F�V��U�t���r�i�M���Z�st���!�ѭ��Ӈɟ?:,Cϑp�7�n�4����,E＄����y!���G_��V6�MU�ɗ9�V��J�R `��?o��a�5��A��<�`��Ys<��:���5�1��k �:�!o�p����;��B��n?F�>?kX�FB�"Y^��7,O��`���R�57*�Ts�0��]D	1\�;�X��v�虡�1,S�A�8e�͆a�z����1��?�)�]`ֲ<='r��M��v;oy�c&L�u�kMoYM�T/����{��uV�<O+d�%ƼW��x3e�\�,M�}ي�~y���׻bS-��xW�(&��`���'�kYH���V�cyv��}t�L"��ݍ�;S]f�R^u�}>Oz��Z˪i��e�G�h��?���K�u�����S��9�~E%��� ���ʖ�!C^5/������e��MU��b'd���1L�2�#a����U�6ۥ�V,*?�\���6ݒ->�����]X�Ք��D�ov��yˬ����\3��4�Z�a,u���~t�tJK�kʃ�0e�������|������݄��<V�X6�G�ݬzޕ���:�q�!�O�j��i�zhH,v�Ӟ�<��jrk�j��=!�Y5��^�4��輽��73�B�ei�.Sӹ��v5�yM��Ct^,,�1ݔAV��\�;0�݇]�6�gSo@��{    ���z����)�i �{	Ϧ"d<ai����ȋ	��fLI�ӊ�z�9�ԁWӚ<��իux�"�R'c���ҽޤ����T�lt_10,M�+�Zމq!�|�gB��i�0Sk�x�����<�q7�a��ŲY>\_�<�zRB	��F{��bd�4����俬����4��^�MYO�Dޡ��ZK�o�f�#��s���,C܋�zmn���%p�#��t�a�3e���pX�h{�M��Ļ�����]:�<��4�kN|x�d��QuIM�yi[׾�9��w��r���]��.�����;(����\�]������[�aow���T�����$r?]�y�p<�ޫ�>���Ù K��ِ(�!��}�`�7j�EЎ���+�d�r��1��CC;xO�����hc����L����	�!�Q
���	�n�hfYr����0�;�SӴa���G�
��x=�Z�B�O�c��8�p4��}�=��8��v
R�#^׿��)b��8|&/��<,Wk�N�r�4UU�N��[ݝ����r���E�Z��tw��b���=�<X����C�h�x�P=�p|�p�T�~@^���C�aHORIu�:��%>���D�5�@��5Hpv8:s�Jh����!�W^^F��	S'@�	_�)��C�A��4e|>��!�q<xHq�eI!�������!�����Hyx?$h1�����8?�fq_G��
�t��r�!u��0��i��㇃��2��m8?$�j��l�]?4=b��"��c��\�~�����C
��ʃ�rm����C,�0uq*cV1�q<~�^���,�d:>����huSٔ+���T���:x�N ��7�{xy^K��bϽm�f�9�h���4_N�vǣ���9@��h�*�,��A��:�L�?�C\���g���\���_)��@�_~�/����|�j��M��of��xM���x�#3����d���D�ώ�x�\���g*�aݿ@�ej�2��p"��g��H��8���B��j<����وk���M!Ļ��Tu��#\Tt;}�" <��A`��+��B��l�	�AD=�ǹ���������z�5�d�(Q���k��xq`LwMj���4_����q"�kWWK�WTjlಟM8\�=J��i]=�J��gQ�`DzK���Z	��>�#n��l�	e��=�3��qH"��Ǟ�������r2e3���ԝ���ߓI%��ı�y���O$��|1�٨r"K$���[�tp$*�dt�](�)�l���zDӖ��_�|߅�y8q���oiPڟד)uꎇ)�L�[U�'wWu����D� �N��t�FV�!Et�T]cʩI�Gڭ8�+��� }�]�2��q�"�����N i����ӛY��2�c\�2Յd���1E�}���j[��tS���Abg�@���ۇI-�(*�+���6���nK/��@E�ئ���/K�� %}�|yZ�m/r�� ϐ��[��r$�1䒒�	)���HK�|ݬ��#
��+��պ\^��e���Jv�)�ڡݔ���?�,R#�����ג#u��E����7I� ��"���¸Uj��N���M�Ï�-�ո��"-f��J:b%Kق�.>�
!>� ��ɿ��-����5Y��R��d~�J�PW�T|�d�/�G�v�H�-�����-�1�L����2A9QxI<{+�J�zrd����LH@!����E^��/��4�|�н�[�4��שl:(.5Ҕ��r�;��<�ؼ�cݞ�EW�5��F�1�u���m�u��G���hMH������*@����p(JG,���4&-z�O�ܽq����1�^y��͊�p�ɣy���0Gz۵U�I	uJ�w�̑�9�x�̊�n�J�ի^hX$��˶�՚6����!](�m\��q)!>�@|��������ET��C�u��n��lē.���<�8��yQM6����E7�Nn�}����qǱ�X�̬��r7���wd�8{�,��JSK�&%L�۞�7-�N�۠I�л'Ju�$�����m��i�[�U�Gؐ�n�{��U��Ex={C\\P&	f���U^�6O�s��S�L��Un7p^@!i�E��#[&}�_��6�B��pR͹���B�)��̅�hB�Q%�<�F�2n݃�1��
GbU_�k@x_�%^=Gj"6˦��O3��K��*�nFt�t-��bA��.Y�O��1�/oS��ݮ�I�M��	�%ؐy3u��z"MB�n*9D�Vg�:Z�;@
��$G�eq�^�0Iz"[��뽦�� I:�e,1'$����Hn_'IB aF(�H�^�(�0	�$�P�t�pIC��XI�����w5�ܛ�i��d�f�d�� ��w��1����ܞ�&71N�%���ۿ�K�Z��+j)Z ���&q8�%��㓨(c���&�2��0�-�v3ݩ��|�l��s�&KZAP��x���1�8�̻��aʩQ�ܶ����i��L���_ײf�)�F%�HIJ��� �M=��[��5!H�OX� %}'Js7�k}�sSH���4�i��0�AJ��A��,����mv,_�</'
o{7�u�J���(o�$E�E39%�� ��f(��n���ǡ�qS�JI��3�_�%h���GR$	_�ȅ�q�`J�s���!��~����0H���S��L�)�.(LIo�;Cx�g��G���('�%u���)i�_B���/	q�Mcp�N8�r3^	&Y����F�p�ēٯ`v9�r�I	�9���y�6�,Mg��%Q���8��������o�8�� 3^7W�^� �;�;�;�wAҙh:�I���x��U���9Z���]���x��4d`��qX����TrX��DI�7���J@�Cu�L���ZW���BfwRN-M�d��i�������!���
L��,��Wӭ/2��t����<�%�UR��}>��`ʱ\z��'2�Nf�?=��B<_���:��4}�y�&c�bC��B%�a���T�~~��ʸ�㔨�J=�z�nL,���t��[��T�^��K^s��b��8%��^b����P��>�y!�km�v��\�Kf�:�.��aT�2�p�6�n�O��QE�0%�K�N�� �^R�nk��
Or8%�%,�����)%W�Z�J��s�m��y��?^R�*%�g%cZ��DMk��zI���^㼸7�HUp �jG*��ٙ��Rƪ�h�*��ɋr����Bhwe�)����$7���/_���š�H��X H�F�,�k��$7�@%h���j=Q�� B?�o�*�x��S_�9f�n�����B����3C�ou�0�����c��Ɩ����mL�}�u����r���~Ms��I��	���4FB����J��g�RXjCx��y�+��,P�J�ܷ:���K�K%��:і�ެu�.K�R�[%)ʸtH�פHq�����s_�	d_RENVf�|���{���&0��S��J����!�"(|�$�Ɣ��S��x�qT�b9%��_�6��D<O��Kb�}m���P�-�k�k�O`��IO��c&����1�3�\j��^^�L!�W���m�Q���c�����4����5��Ȝ�_=fF)"`��L7w�i"��M�4Ւ.]%�~�m�gR��nqG�ݹH )���sW�\�^OV������:���������my��Χ\ �U�"A���������D�v��ǮI��I�m�{�&�	�ӆ�*�BI�'�!�Jfz���E�J����k!ĳ5$�@í tM�/S�q�H������.��P$�����.�o����c	N�壔�)F]�(1�Z��u��&�S���Ӏ?J��l��UZ�7�!��!�[.̅��5�� �~א@I�䢋=��Td[���I�%�Z�ޜ*#�q�7B�hmO������c�3�nH��&b�UO���&\SW+�J�E��'��*v���/'}�~��(�x�*�؜    m���6�$�_ '9Q�������IR�,��ɮ��.J�[V�T	�TI JOx)5�4�%���XI�N�ЙҐK����ݖ;��w:|�Gܣ�'څol��;����$2屃��HD�-��C����(})"J�H�.J��]���}����ɔ�]A�'I-p��%��n�|l�ha%���t�J��M
1��E#�c�;��$-^&���mwL���	���Y�� m�K�ə2�ܨY::\�DV�` f���]�Դ��H;]tG�G%�.�d�y$'I %i7Oϐ�y[�E�$D��V���R&I���^R"7/���"f�PV����Fu1�����{�4Kt���U��
3
�t�|�Q�H�
V�����Ǻx�$x�N�y������ju���JGb5Qq��c;Bm��
͓�M�y����<r&\��_keݽ#�w�ڥ���W��� G�U;��lѨW��L $!��ԁ3B�$-OO�e鑺+�#�Ø#����ni�I\n\h�Ώj_�� G�5;��o�<>�Fj<�R���Yt�<��-Kֻ���x@r(�IB*JA����:.�kwa�&aBk�W�� G	�$�^����㞮�I���lR$=f���}V1�MR� �q�-�,�� �:'�w�Dk�w�?�."Y�j��P�	�$I*-���dG����+PI��M󵢰摔[-{�x��Z�C#�i��/>̊~>\>�)���q����98R�S�H#@�R�Q@#g3u�g L��QX��U��Cg$*%Mn#?�Uy�f ��ھv��y�l"�59ԣ5��I���H�Fm-����4ϯ���ٺȒ���Y�A&�QH
��D��͚�J$-���#��lq�#��ѵi�X�a�a�n3�-7y3�)u��J�N�d���O�e���1i�p
9���%
S[gz� CS��Ҭ�G"iC0�z��!�vIOxJ�1�D���H��`���H�"AC&��C��F�]�dY;z���:���%S�.�^��I�}�.�@�}�I���5,�7'�!���G�Bd-<�a�+�k�6��D\�$̠,d���$E�a����C���[g%a	$���#����QX9,<!Ip� JBN��XA����&��Wnn���Q�	\�gc�x�M�e��r��[��J��1H��m����[�^�Gh�I.�In��hrR���*�SeB����&9K�ޖ?�.�8�����.�x�*	K
p^)���̶�6oi'䱴�R*)J��I?O����$�ԭ�#��wV���́���Su��kr�;)��;,�j5&u��&g˪�ȃ��.��=��6��g��)Á� J�R��7�����U�%��ݐt�����m<&9�� 0�Rl|�y�,��|	I�-cF*��;B�)�*���/~�sP5\F��k&�RRE�R���.��>��re	)�oD���ʻ27?r�$��M�o��g_�?��u7ug�����vw���0��4Z��NPl�GBc���!Lg�X]a�+Y����J`�MMN�B��N2���`8E���}O~1��dW*{J�b�B��w�$It�.p��!�t�}?���xτ��u���=1'?gw�F�T�JfU���7�6��-�	?s�W(�p���q��Xq����� ��ă[
��=8 x���K�5/&��w�X6G��)�R�j�D$��'� �[��UV
~��,�@�c�,�����mN�?.v�����3���m����n��C��B��n�8�i��)X`���������y|8ҡ�Osi,�B��P����M	��Sv�J|B0�[��)G����)U1��(#��������w]�p0�� a��&ܩܑ`��ՑCIYj�=�]'�%��t��ͨ���v�J_k�V�K����3��Y��#�}ʜ*����]?Ч~KĜh���t#�Ғx����^n�� 	�i�,h j���t���Bjw�M��	�=)�*8���Q�k�j������ʬ�(���¥(In7�NIg|��߷>y|��R�y�r�N�W��?W���i!�;�t�BR��0�|�$�@i,q�L�I�0]}>B�s�<�GT���u����4
��t�F����0�Rޡ�1ƤX;?}�-_���mm	]Ki���ǩJ�FIw-aM�\�ʑ�_)�F���p|h�=��7MRX T�vzJ;�n�[.��Nn{�ġ��I-����$ mig�k�߼��ր����&m�,o�;�K6��W����|�q�w5�LNI̯"�2=RS�I�J�/�H[�n�e��Q��I��\�?�UՕ�<K�0 ��w-���/3]��*1��hj������d�4�$ ��LI��V:;�s�H��+�$B���~I��ˀ�ՙ$\Ԓ%I�)g򍨳7�i�����;��;U�p�{j{�:���-HR9��XVp�e�T�����wI��6LB|��Pn.�֙�)7�����L��&q �U���,HJ$�$'�
���.I�	/�~�9�r3z�	�� A�O���� �1b��v!ʂ,���#u�=	%���S|:���I )����� ���IHp�Z��X#�F��4I��˿� O�gK-�mH�H$a�+�P��Xt�iww��%��V��J���I޷�{�I��R���b�$��u�������&�g�Δ�,6 AIh��~����M���'�e�..!�r���M-�NR#B��C�7b� �����%��t��:[�����-��1��oy|v��䀝�i�z(�o�������E�����r���v��&U�گ��('����&�m��U�L≖� �&��B�$X�C��g���IdIk�,�=da�$ݿlڀO�;͵|��6X[a�k��-�E������#�8��׆ٞ��?���ۓm��=��%�2��!I�+��d�;�
C�쒀Nҩ��H��M�0ϕvaXA�я�7����� ��IZ[������8lr,UV]P�Xӓ�<W��u�p�PIO�q�$�K1�͚׵�&���У� �lnCޓ�M�?Q���TyCTʯ�k���4h8�t�I�&�Pw8h��S�9�	��	�$���	��:94=��L�X�]��'5�7v�JV!�IjL]���A��&�5XZFOԍ�tO��둹A����0>����Xv����a߄�(wVO;�	 �+l�cb�Y�369�b��^��n����,�d@�q�$e���+>��0�$`���oi3h��i����hXM�-'�=8Q�����I�KyVFU�E-	�`�bUݕR:14w��������͓�=A��t�Y|%a�+��d�o�nIP���B���A�bKJܽrt��������Bj/�\�!ƕ�fiEt�
!>HT��׽���բ���(����}Q�0I;V�&��i��1��sQ<2I����O���sS]GY
�å����w(�%�����z�����B�W�`*�ݡ�Lc�g��j��J�S�cS��B�w�g$������'��7�δx����J����gvJT!�O��.ep+!{b�t���x�$n
�O/׾�7�ZBB����٤��r��ImTo/�gN�2!^y�}�	������.e���ݐX� ���"��+^�J<�q���2W:{~�O�B|�B���S*�o��I�[uI�L�˔B��kn����d}~7�'(���e�c/%�]4
�ʋ�)ƹ��JE�g=/oX�G(�}a��Ւ�I	F����7p�L8�r[�������=<|ޟ"{�R�����:@�(��P�Լ2��m���� �L�}��R����s�xG<�!��}��O��ܒʞn�m����ݝ����s�:|%�]�<����քA����k�6�\W�u�W�x,�%=K]��@%�͏�tV���r�<N�Q|��Ӽp&M�o�!>e� �7B*�p��x�b���o�mu�3��f��c�=�է̄x�1�R8<���l<RI5��'���i�����l� |��V��A��fz�]n{��lY���mσ?�m��T�J�0w0إ�SrH�f�hWoc�쯿�/�	    	H��Nb%��;�u��T�1��arٜ:+�IӸ<T9Լ{'\�n�`��p��Z\vG���M�*I[��B�D�_������tt-8Z	s��JH�=�UO�K��P�����*�}q�k��ޱ�R
m�t�sWJ�2�����1�qW:1����&V	>W�0��B��DF2���ϙt�����5���dV���������5c�	��*���]Yr+�}ֿ�ڀ:
((x�,[��(7z1��^Z��?��#ρL�#�↌�Jr8'�x�T��f}+ޤ�ؕ;���8:z"�Te���V9�)�#�s�C��nN..S�H1�U��Fc�-^��Ht�r@(�A ğ�x��H?�����yJ|�% 
	�H�K`L�d��'P�Io��R+���(NGr/+�MB�	�VҘ�qB��G�k%��� �A%طS���En՟��(ޠ*7��6J3�tZEY�'��w���AU�x�V��A�4�AU�Ѧ�pN�L��f8��,�\%���zLM(18ѸJ.��6h��D��Ā�m^o�d�Q���wS2NK�Б.�u��'�'0>\	)4�r"�J��<X8�JF%Tk�W��5�pY/�j6�M*T���Ʉ��/rt�r,��$c�$��~�P���ԫ(��z����v��t�͹
\��L]%�L%�>������9S�!���&��AT�%��U��֙J_ೳT	�\�����)����@\�Lu׸+�t����hJ=��ij���)IK:ђ��.ޛAT��- ��^�^~��Ĩ���$]��ԈJ�N}%b�!���Q�x�&;>�ٓ�m�r�n�bJ�M�FU�(!�>X��Q��㖃aL�Ӌʥ��9��R]�����+m4�������c]I��9M��R�#!��>�~m+�q%(���c%?(�/�7]�\]J������ץ�bj�r����ԩwr��wUψ4��w���p�WS99�����M�S�^Wҽon����c��vٶ��rF�WO��B��v���K��n]����õ��^�7����R�y�8��7�����R܇��.��6$��xr��;g-�`v1�X�~�]:�A�08oA����U?�_�z����r�5�_u]�!F�(Iur;K�:��\)�l�i�p�F#����rq�J:c	Je;��v��<������Y;������H9Q��ݽ~�f٪w��Q��)w�h�8�����i$�6��嫓��P*#5��������G���c�5�F$V�������ӑ>y�ʒ>U�ԫ+Q��#������r$]��������,9i�ͷ���+ױo���|ծ.c�7�1�c�L���d57��X��#���`t�r���6�*�,7M�q�SW�"je���e���`G��Qg�n˾���}O���[� C��×��B:�C�cZf���kB�t����������T�6�R�����Wc��bݗ��hK	L���n�u�kZ�K�z�t`�6�����#��^�Ғ[
gg~��g��|Z��_N��"�9V��?�zWW:K��s�oJԸQl�'��ё�9�Y���`�x�p�����Hq�����(r�㪛M��䂴�U��tz+�!-�y�t��
�X���t��������6���D��
S�O�= �#���"!����r�QW����GT����((rT\�˷��t?%�}{0�c�Q\x������L�5��k_���b%� \����bTM�Acr�f�aK|�?�__T�ZW:��,��DN���f�;<�y���h�Ê���ę3�T�"���[�-�����z5&s4�S�Fww����L7,�?-n�C�B޳�r�,Q��h[��v����@��9��c�Y/�[���a��<�6� �Vt����s<�El����G��* E6���ad�G�)9cOCh�d��]_�)�0�c�>����s�(M9��Y
x}�='�S$��	M�j��N@��oМ>��汫:"�Í�K�E�
g������;G�m�g��	M4uGQ�e��/O��a��L���e���v�ɨ���w=�J�' ��S�'ٶ�)�mL���ࡌq s�ŗ}9?�k��b���d�`E������=!�2��(8�/� AZ&ӡ��_r�`3&��:�o�>Sv�a�T��
��&��ݸ)t�tfs,����X�I4fP� ��ѐ�ؓ�|F& ��hX+(_1dSšz6�G0��������]q�SW�ި��΂��&���v��'�%��'o����i�s�e�Fl�X������t�C�zc�%O��w��TBj`!@�y��y���5�BDN�Nl��8M���~y���rM�ε��;�pF�X�m�:��O�YA�F�������)�3��=9�1�S���ӡ8i�&��(y4,��D��Km�]m�z	4��j�>��������׈M���,D�����:�9t��=ݐ+���E(m#
j2.D��E��^F��h��^�4�\�gd�`vG���b�v�9��@.�~��X�����V�JL�mLF|���Z�`��@cMc�v�6 L���V��7���Ϊ7�19Ob����iq��K� Ƀ; ;�(ͱB��剁���&}�m���͇�W>ՕN�\��c�m�_��q�cm���U��ԕ�ݫ��M���mڦz�j߼ru��j?(�F�����}o;�a*�k�-וF�����e;D@����TJ��D�sL����˺�i��p��וֻT��>���T���Fw'�Kt���^�9�Dt�������[iVS�5�F	w�&�I�J�Fbַ{}�v{[�j�4�Dv�����@����|U4/�����X���i���a�.�틒�K�8��q7�D���ftNs*-�F��ǿ���T���]8��h��N��r�iƧ�[�9M&��fi�p����Rg�~�a]��<�"��x�p��}d�^A?�c�����x=��0Ӛ�qU�n�y1?d3� LsN-�������
M�U���t%5 k�xj�&sQ�9�����NG���!Tn����9VY���q28���v���=��zq�.K��&��,��P���9��b;���Z���>�����a0�4�"+��	�E����vdË��tx�.o���+�.��#!�e[���m�'��P��v��b|�]=���0�%Y���{����T���DZk=h-C���-__��+�
}賐a%�~@h'���D�΁-6�M��kcU����ŋ�o+�Mw{���3��<��RWz>�𸳭{�w���¶�c��ed��b�@���-�*8��EŇ?OK�1�^�9�	���m���f�%���^�}y�X_�Fp�v��<�n^4�s��P���X�E0�޲��,Cu��7w��e=�Fqr�C<�լ�S|`�㜪wYj?�lJwY�	OvX�*��D������b$�ҧ_*�X������hN���#��� :\ُ��.�,Q����ɠ�������w������Θ'F��ۇ�!TM����VVy������K7i*��]f+@�Я��kn�����l�[s�z�y�V��� E~���޶tڪp?�9q����^���8�ݙ;��:S�C�㤆�>��gJ���|fݞ�8\�l�C��A�"�v�'��ԩ�M�U��	R�1��d4dC=a�Nz�^;h:�TN�z�G���)G���Ӷ����R�I�5�p5�l�l���)�f�`;y<k�Ty�8�p����Cv�C�A��Ĥ�x�P3��AA�;y��7U"#ἀ�:[��1-giJ+��oЯܠ;�3@A��iFC7�Ao9oo��VW�5p�8y
]���5?�n=��v��~ў��s�j���v:�{���'(����D�muo_���+�f^����b;������ <:��<)9�ի[QP�QF��!c��HЋ81�����O*Ky|QW:U�5]��59G�?�Q��,�2nD��(⤨��}W҇������{]��v����J�����B�g����J�'\`ά�qB0�d�    6�d=�: ���R+[Y�lv�&�2)��&Gegq�.Ď�+ܔ�zr���M��W�K�]�+�⎛r&��%����wD7j�� ���Lnc漅e���O���D��90zz9�0P,�wC8�ZbU�Z,��߂ؠўc�b��3Lδ�a���c�@ln�Dn�_0hO��*����P�(��,�m�Pq��e�����8�H��>ܓȀ�z&<]K�T�a�5ғ�X$l�S�M��ÉD���B�6:��1��P*�c���~���m��iS���љHv�t�h꧎��d���e��S�=�v�3P�'r���1��(�����䎉%/(b�iOL��R�ҙ�}��bɵ�]�Y�!�Γ�"F�ʤ���#�9^��Re�y�2뺛��Ov�
�mRE�FA'7������
�I�M f$
Vҁrh��ܟQQFA'�4�0�\	����N7=Q��9�mo�ֱ6�|I8/�LϦ���:����rP�FI'�J �7�==�.h��4�"�V���A/��A5�c��E$83iBFcm��)Cl���'P�,V?�t��o��l�M�_���O��>P
"�:��um��q:��i9P$o,�ݘ�)�[���wP+=6(O����/�+�VL\�3�´R�O�Ԯ�<7K"�FU'�Yw��r:�M-�o�����1t�s����@AVc0(O&�r���r��9�P�_���ߺҩ&/�Ȋc�8OS{���պ���%�Ɲ�=�ګ����_O���Š�NcO?�޷T���DϠ>9�4���ק%Ve�q������z_�f����gY����7e�v����f?_��i_��ԕ���{I���/�cl�N{���5r&�?��]��Q|Q"�,	�_���sZ/+�'O|u�!S�zX߷ӝ��HG�aY�����KΡ:?:�	Q����R����/�YW:�A��+�zsȓ1�;�KGZ�x|Q_�R�f�u�sP3 S��ۛ���N����^�T���5.O�וt���
��3�yWx��|����|���q�l�,�l,����W��O]�r��4��c�����/u����� n��<%G:�{y[b]I�C���5���V�o��ԕN�ee��Q��2�t�sh��WsO���&��o�9��h!�����H�M�U�\4��썟�߭��:]c;o[�U��}�K_�R:)��~Y��åt1�������ӗ�պ��`>��ǧG�8��өO�\�Z���[�ш9���z��k���Cl�t��v��2L���O����N��tt%1��m�fp��L�b�� �Ә�Ii:�+I_�9�/˺�����|Ұ�4&8JV:MGLG�*K�t�g�;�r�Ж\�n*ܽ����ת�����쭛!�jl:�9��*�Oh������v3��Rz�=��ƿ__6��3�tW�i��]Jq����St`��#�2�������O��.�W����J�>8YK��%��Ǻ�^�LI���Ɛ*��:���)<چ�=�x@�����X��Dq�Mm���p��j��O���eϫ�~=wX^��]W����V�)~�v���
�{x����<��y?z ��'u/l�:��d��u1Fq�R��q��n}z�����t&��;Jt5��5����wu��,�l�S17*?)$j���>%�S�����&����N�3*�s�-�?��A�W�x,���4�s�}��F��&�����![FD䕑j1HP�'=E ��'.�Q��P�[����E:���QW:�얎�~��T`c�8�q�o#R����q�#�Ҧ�w�d�٣u�ES�;oxyq]�u�Ӝ�tt����7_oh�����5�^�U�@�L�TIWu��jn	L�Q�9�C�5�ϸ��*2��4�Q��lFC["�o�S�.�I�\)`����?K�=}6���_��£��O�֮�4����!�7EC�`�`�$��^�4 [���F�f*��f�(�d{,nݰ}�Ӧ��`OT+uQO���5T�i����RP����?::\�L��ˮV�|UՊƀNc�v���(�/���;�D̦3��l+k�)�u���k]�t�ʆ4S�����}3xFS[��u�^��u)M�S:�LuǨ^ՇB���I�U�(rW�ƶ�����x>ќz�'j�t$k��_�[>>}���޺k�8N�4:�~:P��Q��-e���A�B��1U�M�t=�� �����^�+R��h�|{�U:u˷#MC�:PIi,�ؕ�g\i�]��3;�y�d�`c p3j?w�V�hia�t���h^@&�X�!A�Q�IS����)�evȴW^�1����9��x��l�$�3�<��*4�͕?��)n�^���0룚�?�^��N��Q�ɰ$�:]��hp�;^��I���z�'�e����	������p/%�~�x�$lG�.�� R4XP����|1=��1�FVf����ƃr?�����1���F��P�A���`O�5C��l�>Y���E����n�Ky���ht� �`�6��^����S킧�
��`6��<xC�i����Ii��QO�Ro.Y�)б�<F�Fd5
t6�6`�p4�?)u�7��9Q'@�w�M��ƕ�<�[��ׅ������UǦ��G� e��b��R�G�=Y�]�Ɓ2��̸]7{� Amj'c����	~b�tĔ�{?Q/ ž������f�;�r�:`�s�E�&�:�w�������QG����g�ʁ��że,p�#��7�7-+�My��1Ɠ�K��HE� �t�&��(�ﶾ�;j��<�'%O�`@�ΫryFO�3��a�GAԜ�$S��O�4H���^���o�����uG����	�Q�*kI��N��Ù��3�G-ޏA�rkgYF�bt�����V�#��S���=��n֍P��e�r�:���j��4Z�!��׻+���%[3�c�KȞɳ�{�\;�.��m�9dׅ2-t��˞��>�ie\9*e���lnkަF}N�N����a���?����
x8��^���
�?�,{
�l�ڹ����������ج�N|��0;�&�"�������ԥ��!��|Ѿ���7�V\�Q�0����v��^<�_J�I�z�'�h,L�9��iYc[Iq~5q�=Q����K�s�I�YkCv]�����?__�pվF�'%=7Ǯ/��F]>?^d���7[���ߞ��}���>��"ׇyB�dU/%�����[2�ݒ�jd�*���ӯek�W'?�4����S��^��<i�?��vR{��W��~zzȍR��W��1�s�=\7˷|8�������%Q������N��|�a��D��Q(�x}y�[[K<9�kϖ��U��'wsH�
ز��[��:���ʴ,;C�?��O{���vz��VG�,O�~֕N�(��ɧoŨ�$4�M��b��%�O�Do�ZQn馰?����o+����I�;ʹ�Z:�Hy-�J�,*J�w;S���p¸Z$��y�!�ؼ�⯚ܨ��j;:��}X�<ԕ���fN{�-c��-?_U�ƨ�l���8c~e�Y�Ԃj����{��fA��rYS���-'j9g^�͉>��,p�z=��1��2�v4ӏ��+������7V��bTR0���wOo�$֕���RϡH>��W��&{�F��h���ڎ�x�J��<-[���XOiʁ���7�S����:�g����|��X�oEc�'�s?<=�*�������&�|b���O�z�0�J�b���|�Y�*�l=o��@�N���[Jh��)�Y?�����xܲ�1��{�L]�� ]4��{b���e'���}�}(��s�ouړ�,�+� 6/i�'s�Wh���]:�A{:�U��V�Ww��eweoK�*���
9�=JO�9���	�����bW��WC<���@�6�}56��'��-ŏ�3�����{b������R��1��׏��J:��jNG�/t�ړ*�[�����]v���O��Rz�~B�k(�B$��|j�q��U��d`;&��zŉ^Iz    ���� yx,�}�8�'��ּ�p�=}^B�u%�-�2����"�3Mo�����M�>�H)�2�W"C>~Ŗ�cH (:��ӓD;���O2(O޳Z��r�>�(��I�W<��qހ��#��y����8��)�y���
A�֦Z	[ۑxr&�n���p:�I���4ɍ�^���[��r���#�J#� 6tZ׮єpK��-lo;�i�AwrC�� 4HF�'3�+�P��X�tNv��lx���)�Y<��dhL�Av�`���G�Ş\��- *��j����y�y	8���ć�	�p�:��4�s�Xp�8�#\'O���vh�u�i���Wb�Nb������o-�o
�|��v$U�[b�?��d�2V�@C�:y�@��c�=�K:Ӊ�=�M����F�'�S>Rƌ/'��FvN�Z�N���i;[��L��d���������nhOҸΩ� P������\'�b�)��\���'i���,z�'^�À�"O��O/�C�������Cg�x@�0�d��RŜ��+%}�'*��1�|�)����F�'�������aN:�ɞ�_�<VI~HF�[�w5I�H�Fyr���4�s�Ř����νbc��0��M>޻w�%䶩3��^'&���q��{�XD��"<��D�p�,:��?�8�!�C�'�
q ���?��*��x��x>!�5�և{oL��������J�<�'�Wc`|����|���ߺ��@2ꆉP���)��A{r۩Ղh %#�����zjN�HOr[ݯEs ���O�~+��8�-�!��	�q�܃�I��&�R�� �]����<y��':�1z��2�Л�!�՞<O�L�V�(�,xe�W5j(1{�I��薏Q��r���ܽ��\�XOn�������=:3:�B$��k>]i�'J��L��љ�y�HG�|h�r���	��|�k�[C?�������~��0:݉]�3��cv��^��fx�V(,ҳ��(��)�W��&�gRq��x�)�s�5��۟wn�aN��
���P�F��w�@om��;�h�`h#���W�]�9�T�dTu��.�(�����LOn_����J�\|��Y6�J�X�7�����J���X�\�����J��m��۞����վ�P݀��6s���m�Q��~�v_rѲk���g��lY�p^���u]�w-��vS#8s	�??�וNk�]�e�;x�ׯ_��w���ڋB_�bBX�~.u��Ap�%��J��Oȋ�����k��tQ��������ϗ��[ۖV�&R>�x.�>�ut�l��ޭ��%*X���=ץ�~+�V��4.U+{���ݗ���X�д�\S&�q����u�����k��g��/�fr�D���tvs���%��|���}�U����0��7���>����V:�WS<�H{�������tz�
h������_�W\�Pc�]�79936S jU9ʁFo����V��QUg���ӵ�ET+,Qo~��HJUPzWۡ�@q�{�=a���Z2��KS*��[:����l�|���p~#3���Ho��_Ͱ�і]���/�έ�n���N�koq���R�ߖ��:8���o��q��J3�|��h��8����.��S�v:��y3��dԽ��@�y�<�����7�a��H����a�B9n�o:s���ƻ�Nz��1;l)rx/'��x�	_6���rq/�J�s��;�L�@�Vc�'�l���4]�u�;<=[��������zO�@O�|���<�����M�R��O�|�pk��n���4,����gEg8�����w��TWҝBd\�}1pV�rN���J��U���P�����C`w��Sl�;�؜Ze�f1�:�����9�qqV4�3Џ�!s�W�N=)�&>�7յ�1͓����N��_iy���+�Q'�a��_^�Q��y[��S������K鴏�X����'�<-5g��9��?�Y��E�m���|�Bޡx�l1�|6�?/�,���hڔh_c�'WR����ݜ��jJ��c�'���K�rz�J5�7��R^���f���A���ދ��،tx;������c��i�T�[�сh��$p1����Z�V�Mg�t�E�\�ߋfI����S]J��9B�n��@�h'�uJ��Ϊ\���d����6���)�E�7Y��c'F����ob�~0d�w �Xog�(TM3��jܔ.� ;\��S�(���Ӧ⁾��N!� �٤�H�����м)y�:���Q=���w�\�[I�����IС��;�w�SxfTu,r����r>��-����
�W7J�7C� �֭�$��o���3a5���9�?yo};>�Ap����f����f��@ɳ�
+��v��g�^�<�&�)�5���p�m2�Q��	�����Y��|;��F|���ԉα��35�D�FM'䛵?e��V��N�]��`�nA5F'ۂ{���.�%�%�#��k�9��N���VF�;w�h�''�f�ǈ؉6��I�vU��o�� K6��»�԰��=�άs��ٱ֫Z��^6(O���o7���"d����e%5>-�B6fy&<%�ۣ&���RN�o�yI]cf�R[bx9kt����|K����=�=�uji�A  ��R�Dp]AW)Y'<h�n�m7��������9ӈ�@;ec�'O]����M.Ju�1Jp�WĀ�_�sY#<'�5�9P�/��OP��C�nt6��B�[�����xY�;Q=UM��JE�\�;�p���_9¶٨�)�>[����(��Ѿ��38�|�x�agCn�d���G��� *���=p6��[Nؓ>��C�`������ɩ+�r��$��s���1�<X�t��6�A�T�s����,��E��	m���N"*�ĝY���
~Cƚ��ϧ�����am��o��o�YO�ŉ��z���^Չh��Y8Eғ{%����G�hafo�-Qp�l�uB��[ћ���N�V!���z[nMT~-A�PF�hO֜�u���7\�P��9��d��=`��9y��m� ������Ͳ�APҬ�s�4����,�����{�:�8�'�G!�.W:�+�>~!������Y�9��D{�������� �Ǐ��+eY)i2Z=�̉�<�y���3��=iħ��n�e O�Q����t5��h�|;O��t�}H�`�Ve����x�#�n�;ĝ�������ZЈ���V&��&EpRf��1�Fe'+���p/Q���eih_؏S51���8Zu{u�|�>GQh#��P]BЉ�E�j��JB�ܓ<q��?O��2kF� ��<q�}#��&�����2q������F9�B��D|�x�q#n�	\O��t��	ԕ��י�<���%��/w��3��ަ<���<6"&���6���xb��J�|��!&��x⪗�Q&)˓��y�O$��DOp�	OX��4�C/�!n������ѼGr��'�sz����T���h�����^��Q�f�
.鎦����`��fKY�B+� Oħܴ\U�UH�F|:���3>��%5��]��M��{����c<;��~�?�@輮3�͛Y*�'&�����:o'&�k���ć��[>��u�=�~C�q�'�Ӟ�N7���륝������cw�tv�-j?O��(�돑x�2Z=@~&����DJ c_nj">�]���v��u�5�ڊ<�HO�\/�D�Y���1W�ө�{JSt$�ԋ=u y�O�Y�o�=�;4�s�(�[+tP&�s�@#��.~��Opn�A��f��;Re�>�PQ,qA��+��]��D}N��q����]����鵮���0�Tt���垣{`�E�Rz����m�p)�;r��ћa��ų(��íG�eb@'-U ?nD��-:���w�;��� ѣ�03D�8we�@'�'@]Ǭ�;�^&tz�5�	ӵ8T��H�P��9��0���D��>�KD��@�(�� ��Y�I�Oi_� @�	��5���<��b��H#Pr���:�Qtt��V   ��G^�D�Nn��z��p^ݟ���|��٘6�Ec?ɿ�O<c^*��p��	��kPg�BJ����Tq���u'�L��l��
� �*�IԀ3�= B*�9=?h�]O +�9���`�1ê�QE�?�#{.��=�>����Y�L��~~�I��L��:��2��2P��~��;Ɨ[jEjb?����j�&�s��6�t���M��d�2u&0�n��}N��v�~:]�C���˙��D�N��h:W�rFɔO71��JFgl�����Op|��g��z�0Q�����fѿ�9�g�x+��V�O����]��>�<���Oy7Kґ�/:���Vr%-wlb?5'*�r.�|b?'���2���Eg?���^1��x�Wm���}��*�Op�%kc�#+�9=�҆SBL��~���I�A���PI�xzk[�!6�ӧ�7|���'ڼ �m3%+��`?���ژ�'�QI��O������'��JO�iN���;w�����r K��'j�mht`�c��,(e�26"��~��25�2�T��}��f��b.Q�V�ɮ����}�,!�X�>a�@+ִ��z@��ˈ��:�y��7����Î��u>�Lħ���$�>`+��t�30�9� [&�s��j�Y;>����9A++倎����*nO�c���i����p�gU�N����G+�̸�W{2z��Ц���L�甡�۴���=�z* �}m�s��;V���$R�<��N��	�B�O��7�K��^R����������;'�      k   Y   x�KN,IM�/��7�t��-(J�H�+�,KUH�/K-JLO�44�3�J�)3�tJ,�LFH��#Iq�&g&�dV�� �a�gd����� �{%C      n   w  x�-PKn�0]O1��#R\�+�ݦ����Jl%�&J�������y_���٥/x��%����ͅ��J��y���)5�v�]=O�K�}���H|����d)�*�JΔ���B�z������[S\�5E����x�������R`T%����m�&�h�����
P:��$�4hU%S%<�q���A)U��s����#pc�d��{LS����q]�Ӱ�<Mw�RT����a�o~m�L3�iK�O�=�Ț��O��`3���H��4��
��ݶ���.�>������>��t�qMh�b��kf�˸�c� ��9/�d��N��ݍ��^)VP'��z��9X�����%����4��Z�~=0���B�]      q      x��}�v#9����+�z�zA6�aIQ�(��DJ�tކ!1#��!FQbdF��[���K���O���>�������5���&B�l�~]�e7�Ӟ��d'������v��nvo��K6ڮ_>����o���������x���ڞl�	&\&Y�)=�z�f4{Z��C*��O������w�sFd����z�z��(%�S2��c���~%�էl�e�c�ۮ?����}��f���j�MW?���gT�>���=�2���΍v<��?�+ra���z�_eW��w����}�ݼ�Ç�����O�����gi�j��3�?먽���&���/�V/_����,�>/ç'??�7����}د3i��}���M��������M6ܽ��|l>��R1������:�^�r�[�k\�Wo��w��Liy_�b��Dd<�&�;1N��t�u��"w�χ�j���t��y]����us������k��۾��	Z�E�#��I"eF��o����� �!^F��l����n��θ�>Ϣx�g�x=9K��C�iii6?|:�?�����fÎ+��Wg���-�Ȫ0�B�������h8��^7崶��j�u��~۽e�J.�p�啈3�1��lA,Oq҉�n�}�
����{#���[�B�����Q�a��Q��a�t1N�^*�1-A�����}[�j�/�[��T�[����슜�.ƏJ!T��|��/e'�ǎ+��AJ�_��W
�Z��E�V5�c,���<{�m������NT���t���G�k�&��2^�����/����,�?���>���n�ڰ�*d�j[�H��Dq�F/��yb����c�+T��ǟ�w6̆���Y����Q�L�i��̆w��l�{{]�������e�9K+Jˢ4��6{X���l��Q�Э301h��+���f�����/vQ�U����O0չ�`R���x�ܽ6D��R�w`�ۏͷ�������������;|�:Y�B�8#�-��[�L=��l����yG��@��6��<C9�Xe\[��Jīv񪵙���>�P:��*���MЬ����?O��z$Չ�q<"8�|ʸ���EjF����t���USړ�.D8�zt�T-�Q����\��G9e2ͳ����{����,��Ю/\���l��-�DHSq�BZ�_o?���N&��3��aF/�1�t��^kKvz}F$�,%(�\�w���zm��T�����u�v�SǬV}��h��83�	;[4$�k!��*�?d�;�}�s~��|ߢr����Ղ3�T_�(���b�wT��d)8��s��I�9�Ch%M����jN��  &�F43;��h����olj��W/�����f��x�ׄ���oW���@��%"�#d��g���X\x�n�4��_֯�������6�1�ǔd��t�c�� `�'�=-ao)Z�p�sV�G���@�Y��:�6�g�����\�W�#cLjA��@}����E7�6�;�ˊ,56Af7�ʭX��1HRe'��u�7��)���z �rMO�lx����+�u6��[2z�.7���D��RÏ�O0k����e�Z8���k���a=D2yQ�+h	�X�Θ2}jSmg�Bo6/�������+ފΊ�b)@f�A�r���=��B�)�֍p�D%��33�' 6%F��4�*�[>�y����jh��������GǮbB��sr>>7�VGL��~���	AE�I�Ь܅tl���"���$���Hipo�i��W�8�Z�f�����=	P�(e���G0��p�c�B?���]���.�.\J��,Z�@9�����ڒ �a[���+�8�'Xs]»h�}����̑��4�4��M�bP� �yH	����J�-�L�F�&��25[�~�|�����a�j��W��LA�ӧ,�b���b3!'�D,e �/��2���dSĤ�t��b��2�o]�Bp�IJ��]\�X�mU|��H8Xl���Ֆ�#?�b,����u�� ��;�E,�)x���f���o__����5�Q��H��5�
� �Q�8�3�*WCb(��@<v�ca|c,�v�5���׀���辍��S+�ߛ�*HW�w�I��LKU�"��Sp�`je�i�,(]�qč�W̹Y�;����.UW������ǯ��z��(��S�u�M��C��'�� �9ӷ"~�S�} d:<K�:��J�����9��L��[�";���lO4Ƃ�z]o�|�����R`s�Uj1H�?���i���e��1�#����꿼Nt�!��X�g�|���E(Kn��1��n�_�<�LME�b�lWo/_֯Lڼf����!�NvU�(�ݰ
�e!��ouQ�z�"m ��O���q�9nl��힀�|�R�ud�����,��ȪE�ϏD`�X����7|��&a��
 -�^XU��#z�;%%6�J�� ���6��*]���.�`�>CN��)y`���7Bl;Aޓ����<�o��L����b��>"���O�o	%_�:h�������|������\F��L.	H�Ƴl`u��ۼ�W�V��	�kL؂[��xyay�$ǣS�:5���8X�!���n�cוH ��J�y��89��P\�!�o�T��,���ܪMt�!�+�?�f� Ω�3��w��+�~����yG�Lpa�ų(���~N̘�/Sì�p������o�O�m3������l���SũA��Ō��+r�!�� <U��.ju�/��h��4w���u�Mt���]g��#��Y���2�5}�S7V���!�_u�g��X�75(Q5
�����p��y\��?�A�V�
Y�f����\n�>{�m�e���S2��A`A��#�m��8̽>܏`#�}�Wk�6� �6QY���򙀜�OJ�5� �ܨ�Qե,MZ
J�?��ec!��7w����Z�a6X�w��}j=�e�?ߊ+q�B�(�*w��"�<��b�aG��%����`CR�i�qҐ�x>'�1��Հrm6z�n��.�6�O��/����z�=��UN�jZBfB�\�a�=�&������o�v��_`����1�� P��MT���,`cP�}:|�ѝިI�tF��J��tif@�H���>MP8��F8x���;��`N|�#��F,��������7`������a��4���r.�H��5z}%Loxw�Tjs�,j&��.샤QZs 0��b~�ZugUv�;���I㨯Ԅ���������&�X�v��^�gv��D���6����4?�����t.	5!Bә����&Z�i�X:ј�IM���=1�)���6�(S��Fu�

��$�861s<���!`AWOXpy�f�ͮ���+$�C��e���}<!~s���h�t�5ʧY�50� 5@�Dy��t4e�Z���.V���
ѹZ���1@e��#���0�5�GD �7 �����7Rl7���������q���\oz	��k o���=��T<*UGj�A
�#��dyj�eA(��xf�f���/z7��;X�#�PTڅ����Y�X^�*+i�SiX������@����/����Z*A�J���H�w�����w,�ڮ#X����1WS���݂u�K7W�ݴ�o]�C)g>|��E��G��i"n�gs�&rF��`�L�Eu���G����7�JK��P�qV��˗���t�y4��n��PJc����Yx Pͮ)��.Dx�����h�g�/�|�?����}�N���S�]%���UT\�ϡb� �&��*0Cp@%��RnL�S�l\#w�!�~�\������t�U[-��Da�L��D
��4]�+��j�Bj�=��bd�$�����ɔ59JG��=9N��4���	�-V/�����ڧ���)��'��/F	y 7$Z�jmJ��'�u&pv{�!D9\�Nw��3i�x�h	����}�Gr`��{�y	������C�"�5��?�5 ["��y���Qz��#��3�K@2��-�&L������>ڮ?ɤq    �H'R�[pZ��������H�bEp�e��د��*�d��\�~���kE��:E���x���� +���K�XI���x�L3F���_�=�����m^��
���5�*������L�+�����?�qM7�����T|8#��Ђ�uzJ�k�p}��K�'5>�|y� G����ZEΡr���)t����ejL4!�k@���T�"i��]K�t���۪Z�>�U9�B��E� ���0�;;W���U�74W]��zbl�:]��50���O��5���r�(�C�<HRHPw�"�~����>���'#<%]�p�3�8��)����:L��" R\��3�f��`@Ϧ�� ׌I��0-O�����z�p¦y���?6ޣW��57���W�� ��Ň�c@��NC�Xɘ��v�(�yΚQ�J�R����t8)z�wguN%V!z�y�ز��1!�Q�ɠ�*��)�#v�4�2%���_6û��<;?�}hq�%o�\VL`8�+�{����5\�t��{�CX���͇���1��zgZQ$�NɭE*a��
�J_y����)�F��e^��DA\d[ZM{���J�҂�nf���4�s(��3�G#R�*Bİ�@����71g��?[T��]���! 4���[�QBȳ|D&:e3k:�y-����-<P�J���]�x~5 �N� ��c��5�]���gb}�iE���� N����n�e6�i���C8�����W��te��|��x�������6:�<}rKg��ʤVd-�m�ȫh��a�N����w�SE̚0��a�v� � @cӒ��P/���cu�B4rZog��XK�It����E�S��۟�;t��µV
c	(������`Da����isɔ����fʴ��s�iR�e�f�e�9���K�%)@��q��Y N�&�˘"D����;�ʒ���c,9�������^ nn|��Q	��o��ªS�5r���Q+�$
���L;�B^� `�����|�ɨ�M�,S*%��ytOw&c�C ��j�J�$)��|����$��p>��	2m����
���+������-�huA;��i�1���J�tq�-��97����W�"����Nzye�r09�m��n~�3�YkV�S韖�sL_4Uh���v��n��g�����A�Y�>�Hj$�>����W�ʤʡ�P_� �i��'0�s.��H;���I��n9c`���8LT��vV��`N�pvJIꃽ(�IO�!W��d�4fz���q��Nː��&����3�:(��Q���,/B�K����5��⒌ԏ ?����T�ו�z~��>�6o!8�ľ3i��`��XR�{{�Ĳ�u�s�|��4r`��{���.6=x$96�;4(���'��l~�>�c��g��ꅇ���f�U�m�9�2�����J�J��鋊&Gb����)(P�=����ˠ�b^E�r��lv�8�V�ff�uv.�i�*�XƣbX�̏�|y�cJR������r��?�����6=>$�d� ��
G������Z�a��i���m�b\��#��i3�����bO\m��k׾�$���g7�4d��͌5C3��~���m��������i�[����F�r��Ch��@��P��#��(�g�WUI��2���H��%Hj����c�ú��'�OL�Дd?7z� ��mW�c�	�?|�'bI�b�RWq��s�{g7��!����{�}������W�$Pf���M>!���	f8�W\5:�h�,�%�|�\�.'�/H"NE�4(TJ(2��Imx^n� i4�>U������)Y�3�M�yO��!���⁛:d׀;����?>������.�FQl��<�š.�� �Of�\-d���[�ր^�J�$�-3W���n�UƸ���Mg�FF��w��3��Y?��'��j�x�x�E��H|GNIr�_:z���y$�����p��L�Cb@4����ۀ��������~�5Կk�o,.�ѹ����(xI���-�:�t+��Ώn1��]�A�Q�����\�$>Wh�vHy^f�����������	�-+�<d�����Wq:����������{.3������C��#4a�-���[pΨJ�� �/'���=RI�돌�{R���g�y(F̯���w
^o�j$�뀢p��"6�U+/��&���`�Yu18�����F�����*'wi��ڥ��_���\Y�uO�Z(�S6�R�*:��0���v��,d����!mV�#�g8�qP���Ȱ���}%����D����i���B��n��s�!����Kc�p�反�wE�1��`Si��(˅㡽S0�I��|IzQf�J��1�c�y�s�L�i�;S�]��*b�޽3�R�f�I({Wk��mi򘠲�!�Q���� ^����������d6/:��F )?
��N�l��q��g� �^��^
T��r�XU-!���9��Y)}�\5�_��B����o�� .~�MS�*I��^�[jFT�A�� Ua��I,!@��a1%��~����@_�ɧ�t���:O	���T��b�C#�Z+�w+�.��-����<V":��S(��jr��g�V��r�x�FK�+�k�/�%� �d�)��
%{��f��`t:���_1`Rګ� 9!��U5"v4���iI��j��RS`!e��pT��.���q@xK���9;��#4Ǣ��)�,��GWFX����}�����h�������~E��݀�q!���D����g���@!�=�������<1,�Z�M������\�p�3�2{�rڎtF�(y�
3��Pq���V�8U-@�y�V��.t4�Lh���L܈Q���luR6y�ə�x�����Ȕy��e���e��ºdz�]a�WU���P���T�emFb�+��9D��6�oE��ETǛ��d�������� 6&��H��L��>�F�����\,m1�a��&q�G�#�4����TƤ���5��4q�4I����8ʹk
Z���WkD���E����+�;b ����8��?:�-���J0Q�Ѣ6��ܤd��V��}��!ZCԙ�ML�Sdr_a@�ql��U�N��
�)Ǚ`Ǘ���H�X�����2�XE
8~�dG	�LN����Je���I�Gc����u�.�[P�M4�����+�g=�X%{��qU5�j�c��v!�ex�!��G�ϖ���TR�Bb�������v�ރ��e��byB2*��7��x`��E%о�U��]̉����U�*��I?��ʚ��=m8M�Bgׇ��q��~����=�� AGNo����Ŭ��u���^�@�H@����;�qz����Hi�,&�-Y�P���y1f�`�pE.~��Y�{=�G�rS��Z��9��PN�+5R_Cp~qN�J��cNgws":�S)\����Ҵ�M���UB%�~o�L~�__Si=�֥Q��䴇U�0��'����Ʋ-j����J�-�I��=�	��h� ��	i�Q���D�Iؗ�l�5�=4�Q��v��k�O_�C�j��`�b$Œ)���䴍����:�0y�oZkȤ���i^1��Dv�A�w�ٕ|=MS�����i�:�ĮfȭӀZ�� 1U�����Q���8*�-��daVl���[��mƝ�I7��,�Ղ?V�����Lݵ�(�!��64�rqA8���݀q����5m�ڿ~����x8޾K�OG8�����)匁E9�{	��2��&:V�d-�U��si���OG�<���1 �s�NZ����k�f-����f4@ɶ���e�<�ĥ}��܃�"9!�X��Հ��%�>�gՆz���4����r5� U@�5�"�?F�ni�)Kb*���مl��ɈH��e�F�r��b�%]�ʊyO��<]���l��!l������G�K�Icr�vUq*󴈰�+�,�ie��idԕߨ��p�!�u齔M��ʉh<��f�K>�۶��jMZ ��gH��ɐK#z��&')������'�?���p�AX�Ǹ��t��%�    ��e��qL	|ia	�ET,e I���.ΐN��[=��`(tj�x�G�pG�
��t+j��z9-MÑb�m�,qq+d���T`7�Q�p/♶&�HB�X�Q�� ȬJ�tTO��RA$%�'m$�\�.	�%�"�<FG���[)���2q:���c��5G�j��UQ�֍H=�!M<�q��pK�c.� ,mc�k�,V��瀘��g5y�'Z�4M�J���>�j��4%Y���$�*$��Ə���b8�������%ܳ���W�n�a�˹QRX�}�����$��tK@�`�N�U���^0���L��y�������d����Z�CԚ<������q����=0bRVڀ5-f�i�V2v���d_�_��.2YBk����|&�ox���E��,�����6i����2o�vI�u_v�wVH��F����V��#j�9��� ��,�2��:}��T���-f�=��-`�t�����Nͅ�M��ZU�@I������Um�2_g3D�����c��H�S)��S�,<�9�������ڼ�\��P:Z�|"~0{�z��j3���-6�a���ܧB������9���w��4�����|bf�F7���o��%O3��́�H����uګ(�B��S�����ty�ST����&����>��ޚ[&�ᴱi�Ļ��}9oj��[z�XT�ܭ��|�ȍ%W�����+2�q����&,���f����a9� d�[j}BzSL�˧����!tm�����B].�c�|�8(�x�VťO����<�g0O\��A(+�ZIr;��dv����o��M��X1�FJ@��A�I�z��
"���@�l؛��by��[碥�0��y`��E�W����) �_���_����׼��P�k���� c�]1ȝ��08�*)��'aA��
�3���T�:u�CT���#�;���YfG�XC��,��!?8���7'�3 m��\].O���,�1��ój�X�aMN��I��o�2ʹ�̅�q]�V�2q}�+�K���춹)��@�"Q�v<�k����LD.H���od��A �{���HȲK��v�F�J�b�c)rl��,S?<��N�(K�"A��&�	N�%ӒCA�9ؕ����7�&$�E8_�n����%��(A�&Z?m��dH��}X1�-�/5��Yc�{��~Z�!`KD�^}T�dY����I�8���buB����
���K�Ӫ���~8�� ��>���op�&������<�s�aJ��`�b�a�ܾVc��,ʵJ���B2>W{쏌�jN/22J���l����ܟ)L�!r�f;@����3N��S~���9��:ѳ�{���~�4oΌ=����ږw�Cq�N&�2�H	���ݰ���5J���a"�V�8?	VՖE�vD�5[Q��r	L��i2_T�������O��������uo��!�\>T�\�l���ڂ]?�Y]B�'<+?��P!�Ȅ�_��D����?�~�c�?���:��*�H�C@.�]���b	�Sd�A��q6l���N�q?&��Z����N+pn���H*G`�-�Eg�Ƈ�N12�����2[�{=][�w�ʣ&[:�� *���!Qs0�����Au��~}���
��w�l�[f {8N��aE�7oGb,��3~����*�+_��Kk~�_�A���(��p�x�2�'v@FZ�J~T`K�x�4q��:]HG��g`�˽��Iw5�ߒ��U\$�7��SH�8�靔��Y"�G��<p��`�����K����9Gr:���̵������$We,��%�z��j�3J dp���ڕ=3���jbd��!�_1BjO�$Ok����HZI7�>%�*��j���B
g�Ph�e#@C��!��0��[&H�6_�|���V��S�j]��c7��K������.�5y":*Q�(6rHNl����Cl>�ז��i�Z���� SLl�"T2䋦��9��������;\���QQɳ��M��=�6��Xڬv� T�*i�̧�/�d �9kh$wZ ���ފ��=�!�=�1);�^�[Qa]J����e�E�_�l��7���I?�':�H!P�����t2 �����G�}U�cNSώ���R�g�Ai�1�xqܻG�������T����lU��,�#z?�״�VY�6�n�����a*��%nV�!o����&�v�O9�\
QjI9�p]�8��N��8���1R�c)�x��K������nP&w�a��>*�$�(�t��P��e.!F�Xf�Wc���,VH)	���ѐ�pF\��8����O%%�Y�@�[�K�qy2��`�h���e��f�Z�L9-������{1�6�9�Ӡ'�䍖q��\� ަ��O�Ln>��2\-���#u�����������hp
��k�iS`+��?𹍏��O}�I�f.OV Y�/O�{8��03>0��A����Ή7��.#y߁�N���<�ũ������B\��R�&T�y ���2�K�h�,�M~2�K*W@ej�K�.� ����\Hgi��Ҙ��,�g�啱/�2A�N�Q
��JV���L}a����,3oϊɁsK,G�j���<Ӱ�O5���$n��� �F���|{���y�����C��q�%�B�(�㓋�95L��H<E�%�~�V�{��S?�����.����g�S;��%������۱�C藑Fi���I\>�����q$����L�~cjz�Y��h�`�L���)��]Z��Rf�U8ӷME�+�[��ܟ��TKox�?�b���#t�1 ;��	��8�p6�'82'!7Z@ � ����z��6/>
�}A�E�P���91�I]-� tok�82�=�bg�]�����W�����<R��Ͽ}߯�^՚�+����G��"l��R���e�Sp�^���\Aȵ�]̩�&os��J�gg|�CWh��O�+A�$EKv����b�V���n�7E$�%���v������09����\�m�|�$\T���k���ȡﳸ�SXfz��J����4�z�Z6G���T�k	ѽ���UH��zc�o��A|{��^gWBӒ?{r��]	hV\>a����V�����]��(K�tr}ILˀt��)4	�9LR*�F�p�Ik��L�&u�}�g�s�ϫ����a��5�zY'��������k���4���T�Ĳb�>DXB9�Ȉ�S{ D흜��vhp��p�N�l�3N��6Y��w'D�j������iW�\�b�C��ΉT&J֋�ɥK�����3ș<FR�.�oy�&�rf����l��P�XǴ� r�kP�rm�;��X�:�}��J�[�H���a�<���,������iS����A�D����ćO�>�=�hG�W� �LSŬ��oW❲Z��F��NJ����6�m������ �E+��ܐxX^��t�Qn#��UF�TU���n���f�����2��M.�-4�J�5{a���8�DF��c���V����=[Wy����d
y}=ȥ�	$�he�!�y�ö���d��/���+�\],ǖ������\��~r|�����E7�9+F��4�I�0����{�`B����}��yL;ߏ	ۮ.���T�|K_�c
��q5
�Isu�p���`���:��!��Wq��lѓǖvʴ���n��w����:�[�?��%q�BΈ����i��%�l�Q�Xd3[�x��O�[��|^}����*$��g���xN�>Fy�� c�d�5rn���R�P������#���e�������L7��̾��V�ђ��;�m�/�<3����/RӒ�3`��U/�u�]�j�G��Re6@�d���],�v������T�ƣ�Ě�y9Ek��m�HF)c�D�`���c?�G��4�^kM��#���F��W��q��b��g5]^��V�+�RQ���*�P���/�w&ov�G.��LK5���V���E��tLb3) �  ��>g�O������*�Qn�c�ʑ�Y|�-���8�fF�1��h���O�X�ԋ9V+�2]y"���'�y��"u%��NgC�f��|���+7a��Ѳ����b����ύl�,0}�d���67�z�VXOE�>�>3�b[�*��9� �I퍱uy�3�yu�w%���8=�Q��aڣ�q��1͎��I!��X����=<��\P�����26��!
�55l4�x^�Q��Y49!X�L�i����t4�l |nD"����/#��q<%o���o�!��Ӿ�B�I�Q��+3�!������:y�ɂ����`�˔o;��4|�P��y�<=�!��/("�l�k��ZI.�I��g�YV�/r�D��6)L$�yL�F>�FK��3a\y�i�K+C��k��h����b��Za��)�8}�O
An��(�83)�����[�i��Tʕd�kB����f���[�㗓��4RU^J�/&��]��4a�P�G�����;��z��%SQ�:��CC����a�`�r(��n^{�̢�2��n�����迚'VP0)N=������]��Mj6Z�������cI���Ll,�k��T�Ԝw�y�����҆m��#��]�X�<=%���e>N�ک_�&lW�rh'Ke\�Ŋ�#`��#��إ�`l7S��1����9}}������w��RD`9&t�*%�jusO&�>&�����~N��ߞ�c��T��"j-�>KD�l�i�;�a�85��+���$7ӱB�^�H�i� K�m��2���x64��X���j�y���u|z�Xi�푲��C}O�)q2��0�!�oo�I1��v9AX���Xe�}I�{7���t 8��l1��������Z��s���%��;ѣ!���*�B��4x,�U�(��J��#�z:����>g����^�g�;>��hg�8��ɸ)gy<	K��,}�]C`�����PȘ��%��{������1!�3��w'a�U@�7�ٕ���؎��]=S���[4�#�ט�O�^|�nD��S�bx*�����ꢐ/ ���cт�������U�|�4��	��W��9�������	M�݀(�����k�K�j$J[����h7��=t�$M��A��&��r�����*�LQ��T���cE��N�l%)�e�iZ��������?�?W���      l   |   x��1�0��������AB��c,�9J�~N�3ڝ.�b��gHCݽGa�a�c=^K-�<Ĩ�t�k�1��h�c��sE����<�=�2L�'V�-m��4n���z���9        p   �	  x�eX�rK|��m����`��M�˾��9֬�v$:_���#ፍ �.���2��ǩ7u�ݮW��f�L�e���8��:$�|켺�w��P՗����e�8�+�褍���\���u��)�t\Y�|P)��@�Eu;̓zu:	r+]V6��Up.e�s��]��՗yZ��gڕv+[�A���Y�L��q���rZi���H�[	E��yz���[F�K{�r�D��h����+�����&�CMP���}�ʧ�V8�����3�H��AEcM�݌E�Dm����zIg�J1/q��v��i{�Z�������na^}����[��q��x=�g=*U�dv��c��_�|V��$D��]9�2�%H���vg�}������P����\g�z���/͋2}�-b�V������<~�'�0��Y��bE����=Z��b��߼�0a\HT
��X@����V���	qh�,�yF٘3�~�؏�r���QP�1Yî8��&����p<��>���A� ���K���m��V���[�[ ��#�/yXOǣz5n@	0=�_�p�ٸ�0�\Ƣ�yO�U�D�ez6���ax�p�p-xS��t%�e*�rƠ"[����՛����a ��F��l���p����\w�P��P��_���+^����*p��/���8Do:����q��a���� 7�b��'�eիMݫ�I�Gl%����U80d�� t�a:b�6�M�c�.����wM7p1+�*%�
a���&?��:��Â���@cl�RlT�v�om3O'lD`��Dtڻ%cVƱn�R�V�u��Y�Sc;7C��^}���4+�4P�ltRmQ���P��qӸ�����s!�]����c������D�Q�� ���7[6q��E���wk#�������V����z]���n�~���ժl�O��;��)l,+��B��y���zZ7E"Id* I���r����g(��>������)'ڵ�#p:���4Ě)�J$BR`k��?�p���kTA�,����3E	=�FǦL�d��A�D�_2��d
3�"T����G%��p����� ��I?쪺�M�M�'E�*�)&��z��c���v���ȥ�Q����v�攗�%�$��c�|Aw������.<���R�F�9� �d�A�����[Ac��Z���XC�#�ew�	ґ&Q��-�����ՙ��p'lD#�f��B��bl��O�;c��v 7��F���uX��*�]�\�����^�i���a��?��}2���˖�~��\(9[�����M���M:,�Bd���ǐ5� j7|������e�X�U�u�S�j�����D����4���y1����I,�ȵ� Fv�~B�������yQυ���8���8��$��0Z{���q*zP�0D�_�����5p��ބ��#M�������#d�-qCCsȪ�.�E���sn��R4Qˢ�֔��a�7��<� ��Ϙ"��w7���b��^*�@M�]W���^��~���A�6t��I��
Xt�w����RN�l�c�q�@YO/8@�EA
V��t#_T��l+`e|�\��)]0����ĝd"$MYlp�r�ո�>Ӧ��p�@��=�T��4��l���'��i�I?N����{̣?/��,��1f�)٨�-���ˠ�������v��/�P�� �š�$Tv�67�iNEs�R
��N�+��f�SYV^i�W�tq��#���N��� ��?�꟏D�D.�ЊcF´�����73�b�������������b-�b-"H'�Gb�����6���ZC^�u>^/�ְ�c���N�pY�_~O��C���&�T:���*�n?/��:��*�CK�����~��,���!hG�l�i`s�yH�}<ر} ��Cal���Zc���Y��Ũ�1��_��ZL��j��^��ǹ_\@G��	�I@�a�v@5����B'(��0=��j�p���.b��0^��F�:�l�Q�%-?�u�mbt{*��$%ʹF�#�v��Q���E��.��-P5h��� ���!��bD�?���ry;�r����ơ���x�׬�DK�1��m�����O���íH��[����MxU���(�J�5tBR��yy!��H�7-�����UOt��Ѷ�Qr��k��Q��s՞�5�;F@A��ȸ���χc�a�@&�g�W4sx�J{ _�=��9�����	�!2�lB�2���x�_n �<?p�P����Xݏ����|��;�b#�]&����t9�C�C\�@3�k�D
"gx:�?�:E'��'�w8s�8�M�^��+a�<Z1E��lL��}�iG�}�J�M,��T��ړd�A�"Ɠ����`-�X�x�nY��l�|�	��p��j-B�>M���Ԓ �K_>O��_����^�      u      x�m}�rɒ�s�+ꑰ1��~y[]Z�iI�ZQ�m��/%�D�	� ��u����fN���%����V�����\7/W�ew�m�7�r�o�W��V�l3�4:�i�a�CV�Uc�����c�y��޶���o�U��Ͱk������6�X�C�j5չ�Y%���C7���������ӈ/��OC�ᠽy��i^���e׼�lw]3���j���pqDe�4�0�ڃ5!5:����y>w�m��v��o����Q�S%=Uv�C�L���5w�Яۿo��ul��gwq���&��!i�s�f���|����oZt7ݰx|��澹��O�wS3~�ַ�;�����f����|�������^�bм<7Ufjpy�������a��m��wC��5��YPf��M�8�k~�p�W�Ǽ�߿/��t���┸~��4�0�ޙ�u�5���O�jy���������q�z����"�������������]��`��KT��"�?��`��c��6�on��ͺy���ǋ7�9NC�Әp1ަ�G�j߯��fݾ|���c1�?��ͪ��Yᾌ������	�Wݼ\�6����g���b���Y���㥅��}��l�����_u�e������M�6�d�6�im��rw��g�n�r�dS��_�����q\�k�~��T�Ƥ&;�^�m���ê�C&���ةWY�H�^7Ş�͏�����+73�ƃ�����ܾ�NN*�qI5כ=y��n��v��k|�2����ũ6.Ϲ䃩��Fv���S&�8�G��o�S���݀��6�nQ΁d���C��f9�|иU�w�÷�q�������q�xT�&��G�KҌ���W~c+�k��!O��S��6���\��k9�m���p���?'�o����<,�F���_�=�G�3\9,w��'��ҫ3lUkyM�8�".�=t���Sp��Ό3ﲇ��a�u7lVͧ�Э��~�Ynt�8[�.j���K���CǃU;k��a��d�7%��)M�4vR�����_,��`�?�������Ѣ[�{�f��v��j7������љ^�>��k���w�Ym�O\�OX�<g@<x�߭z�;�Q�X?·�Dv0֞��V�_ݷ�Y��q�μQ��;��L���'l�;�6C����,.� gs1L��S�����׷�V��+����aG��(/7���A���(�{�-�W������/&����Qx��b��	�m����K��?a��$11\�:D\CH<^����j�,�w�����K����)�c��/A$Y�my�����15Q�� ���4=Z��l����x3�7��x�<~,��<}>d�脠#��o��]���+������o�l����3x""7��ؾ��ѯ�����I�t�L��kv��?�w%m6w�����[t�q[DfM�n�LKp���������\J<2����\`	��k|���R��Y3�5^���T�Ĺ߻{x�N������Oe��6�4��j�rѶo�ے���4���I��n�B剳G�.�Cy	��	>hca�k��n���g���Mݧ9g��Fn��?�=MP��LC����E�n?�vBf���@W���B�:X���K�1�ɩ�^�>:�F�g]!hv��K|�s���iġ�3�B�p�c�5���l����m��i������r$	�k�q=k��������nICVɚCP�i_�
vzl���U�[�Ioqg�@C39mp(c|n?��׿�}��	q�f̊D��X
��A0�$m�������f�y��)�A��q$�#�߱�<,�5����g��-�m�b^-�w3I^��jU)���r���� �d4O�hMx7��)Q�հ����#��o��O����~'2J��$�/o�7�כ�c�f��Њ=x���'�ھ]u;�&�a�SDa�V9�7 �*>��v]uD�& >y�!��;5_�7��z����7��9l���	��z8�M���[Ϗ��u9�a�����,���'$<W�x0�7Ρ��\�2�HDF����פ�Vg�6��77,�O�@�h89�>n�������^ʫ�|@TD0����z���:��<	�Ej
�f�	�C���^��#< ��7��F 1Y`=l�f��� +�z�fNc��#�'�D�̓g�!8n��K4�(#��e�&��\B�0Z���/���b{�ː��%�����/�Ͱ���Ϭ�⑯�N���� 
f���Al��%�7�!���P"g}\p5���_?�[�m�>$ ��}�&)�Q�,��G@���|a����@�k5w�Փ�)�w`��8�����r������d|x���3�f�3@�b|�k�Bx_\�o_o6wx��󅙱��K���ӭ��a��ۀ��a��7�����^��'*��M9 E�D��߻��[K�Rn���n�?����3&��IR�Z�H�
�s�$̽]m�\(E� �¹ {{F�2�*:�A�������k���{�GN�!y���9�=�4f17<>�G�rD��HY28|�����R��0����]V<�`��@^� 3�M��͓�'|�o
����/�P��c
	IK�9�'�I�o��� 4�]j
��X��w��ga
�����g85�`ἧ�G��W�	3���{|r|8�%d#0�C#�9��v�1��J�,3C���@��yu���~���u��b^|ˠ-�6�*��ߖx�8־Y���x�Ȃ����.9�F�����Hr���o��)mf�kbG�4��z�5%��ࢗT8[g�O{F2��py��
a��rb0��/׋��Y %�T��:> �Q%���L*!�\P�Ƴ�T�Ďx���0��5/'.�i�Y5����~��n5�G<֧��[��l6&���3��q���n�; +N,�9���:>n7�c�n������c-�vmA�&�-S�R>8|��}+E����yG�m��*�T,%� ���⑼���uaj=2VP�F�����������_�2X�NȦ�R�
9��A��������ϕ��l�<y"���y�n$�\�K���F�����\ ��4� ���E��a,�6�����|�Z�����4�2hF��P@�@Le��ݰ���#��Z����9F����j_��9K�l?��[I����K��8�:|������5H�[��a'����!\!9*�Fv��g���ӈ�(��H�����k�F6 ��dd%���	���j4�\�(n����	�_�W�pwat9���1=Ldрc�`v��-�{[x�=!��7�Eu}Q�?�.k�4��M�B6�4z	k�|Mt���C�]܀��KM�M,�gq^@���o�Z���|�-�0ª�d�Q��p�`���\[K���"�*\�*q�R\�觜�s30ԏG<��o�&FP�� ��*�W�T�a�&��R��FI���q<\�Ҧ��=�����C� �><����}���7߈X�5�_f(g)�M�x�g����1|{ys�돈k?��z�ٌU �"&�R�'Cj/�4���V3�X�p��u߼��� N�;�a�~¢����+RЩ�ү��z-�<�C�H��9�ރ@20N����ǿ�z����1�!Gഇ=x���Z+�����Kԁ|�L2� a�}�'��W���*GK�)��ô�����.*b�V��#���3ksP���j����5�	gxZ��?�%���.�:�˵T(� ~߯����Ǘ�<\h�8g���Hc�X:(�!X�=��y�w&���Vp���p��7�Ԩ��� K������Cr8����#R��tw�;��HډL����|f�`<$n��&�:S
�*4c=�}s#��;~�|yI��m�lA������)����#��a%4�Sy]Iy�'� [*W#cl�l
`�Zy^��f��n�c��F���n�/!>�����X    ��O?ZS�Qܱ4L��p�-:b��nS�~����?��n2��cһ �<�L�)�0{�������z�]�7��5�P�:���-"K�w<���� us�3��G|d^�����RY�Ƭ &8܉|���9����9+q�/���� O_}��r�8Jj$���-��M�@��#���̹���-�+��^5�0>0O5��l ���P3�g<���оZ��+������"~	�M�+��75ض/�ukPB�&�i"���������Zh~H�>��AM�t����$�+׭4�%���#��b���%��}�`jA>���U�m���� ��8BZqD���{i��-7@��'�����,	���A�¦��.�6�0+M�y���A@(��f��m��
��������HU(�~������p@	����²Fy?5R�'!���t�W,�K�{����+?�*�t�l��G�r��U��|�p��޼��h#���c�I[���vx 1ڞ�74�b�����A�t-X�N4MP�Ҙ�E;�)X��Z��я��������!cP3�)${D0.ֽ�a���q�� �/1�s�m�/ѱv|�X�p�Тi��-��K�wïg>������-����%�����y\%���O�?�6�AV?���+����Ϻ"T[ۼ�Ȝ�;�����a7~����H18`}i�5��媈�a|k��pk�t�R#��������~x`1��
�)U�:l�R��X<Nxa<�a��&���_ տ*�g-C,0T�5�{&ͱ4.!~�3���l|N~h��G��5�����%�t攓�OB�d;���nI��A�h,OcR�� �"	�Nz��S�3F&nd���	���iaj+�p�Ξ�-��_�ڥc�\u� ��I�F+��>+Ê���
:Iق�[�vK�6t���4}o���7���윆}Z�@�|\���
'��ڏ����o�yᕸqj��&
u6B~?��1�\����X�XZ���i�����1���v�{� ���@�,�
� ���z�T�?��sM��iK
)^��1�t���,f�r��L�n%-��l�M'�a��h��N4��T< )��f��P��t�a.V�Mb���=~�D$y`�8����~���mh��~���=w�IH���ݏV�]��+ ��bVJț����<��	.�m�m3��Q4ň�,�(�m�ے�0��Z�ʀ�x@����b�|�7�]�M�[ �Y ~9H���N�r����#E��Q���"��_�N\F�v��x#At�1��<F���#R�KYűNHɉD����s{�|G:�4k!4��D⺥=��#�LY�@�d2��Hm\l&
|t|8�pғ&�^FZ)�v �|�te��:��gA��O��q�ykT	qs7��*-!w�Z;#�a�̘�@�ԋ��u_!�L�r���#%iA� rC�
w�<��Y�uwY�U�����ǑN}��׻n9*�l��Bk*���򼥊������|�#�a��)�f�)��2Y��p��"�r�Y^5� ��B���g�V2E�ٶ �rK�$��e���،wH����+V�jY�2������1�\� �$�b��S�,���tH��T�(�+"�R��Idj����5��J�vƕ'm���Լ�'3�͞�����p���{g��xؽU�& z�~�CW��H4�}���Jӕǉ���8f�:�X����Iç8F���A��!�I���H�!=��9�+��t���h&OF����?���_>8UU�h�*�P�K6+���XB�
b�W������,Km�7�����R@�8*Ez���q�\�⪒p6
	���E|)�$�����Yߖ� Q@�D�����8�=׌K��U����S"#�Ʃ�'<d������J8�lqJ�V�"i�U�s ������%8�H����^L�0)�a����j|���������e�0~�}��Xg�1�+-�±9V�?PB���P�&�<Q�D�0s��ۢ�QO"�L�:��,Vy��K�)�v�0�)��-n-x�X-�^Q:�)cS�6<�T�Vڙw�����03��Y
V�e �溇G�2X��
V�.�eBG� hO]
�Gca�S�ܑ����sʵ�׌4P"7�MU�"�{���H=R	�����[�p�D�Ipƈ��S`I�=?Υ~��86+-~��cm��:qf��R-�¦��pasM�����(�2���-�$����*'e�>^깮@�'T���fA[�E*e�ъ�/�� tC�)�bZ�o�_�a6�p�Lo�AWR�y߱����v~�:��˛1�fzNCY3R8�����#��<Ɂ���O-M��Xvd*������Z��U��Y�x��֓
��Î�+)e�v��DY��8�U�y�����1��
mŲٖ�GwjN8i1�
2�+�9[d��kn�CǦaT�$Xq��"g�cm>�כ_MG��emaL�̹����Z��WJ��Ü�	ಂ+���V套S1Y�p_ 7lih�f@�3�2�q�+�kހ)�5D��'mL�t�,7up�6�G��7Ԝ4��E�-�.% Y�����'Y�U��4��� c�e]/ٱa��H�6ȶ��nc�9�g0�M�G��z�/��Q7�F2�$��)��-Bu }�]?�Y�ۏ~u\�L�}������&3�\8X���I�y�� �zl������WRp1D�U��<�9x���U��"���!t�Rtst��E&��%�+��DNX�|H��QT�tU���ss3H.����C̔!D�ڤ���9yj-��BI���DPQCUռ-�N4x٪)�7��pP���q��i�Iq�%�{v��g��HI�x��R�����X��Za��P]�$;�Q��o��uUS�޾ T͂MP�b~��Q��	��x��b��d�k �7� t��FU#KE��D�f$��,Z*�!L�aȱ)%�S-��(d}��8(�! �R��pB�g����sH?.���3�����?� &�zC�tMR#� �*I��pª؈d)�T�*�4j��-l�z��'!��C�4 י���ͷ��|CM���ސ�3~����(�^c$OM��Q�+����*Fc��t�=�n~����m)���R9
�×�j�2l4؂Xy��sJE ^�1`\��t��(Wݯn�)�w���
�,���qԱ��V*���1��B:Z�����`h*2�s��~o�@;�3"e�ߗ\���Ғ8���eRr9I���Ӑ��Oq����|�#n"��S"uɦyu$�>�F����� �':�8OD���c���+�J�_¼�T�B�R��_QF#�Ɣ LJ���~�����L�'3�@�ٞX�r<�$\����'��3p3��}��u���a? $��р�
�+��@�*h�Ut66y`�f�l���qc��r�S�V�sJ#�C�5�L��+g�S�v1*�o��3��Ej�B��GJ)zm�WG�Q��p���/t����r��*�4��C�o8������Hqe���1�	<^Ŗe0�����Rpq?:V���S�P�W��I!kl*7�2u�mn���-�ܘpB�h � '�L_u�c��:�S(�	HzuQx	 Yf�3��8;�?��	{�^��)�6Pc�".���O�Ȱi�xɀ ��K��-�)`Y�����	2:d�����{�E3E��q ���ȮHc��qT��95@�0���R��RQ��Kqg󍽌Z�C�u�`�QǶ�U_ ��������ޗpQ$Y��TF���4�4���
?@��!��Py^
_��nJ.��陊
`��C��P��J4�U�R��}{�pRޱ@
d��B`��i�@N�j����h�' �!gX���ڇ}���n�unͫ���w�@m�7Mr֝�L���n%Ţ��K��ı�E���X���^����y��[�l���85��x�i���O0�d8�]h�H����V�J��g��46��    SUs���8�4s ��0�_p*���g�]y~��1������+���EB��"7Q�?��?��K���V�҂.���d�>$��t.�ՠiq[�'P�p:���=��ء�cV�*ʾ7�� � A�>�껯��w�ٔQ!jFj��������a���i>,�;D�@:�	"�4C�f��:��~�y�?6�d���'��2.O���i�h_U�Y_�"�хv%�f����aa��C��2u.b,N
�`��W�Zo�'������La�0�h�H��� Z��H ]�3�Y��9�W�5����㩨cກ�	�'�@���P`S;C�%ɕ��4����0���!e���B7d�'+��Mz�v>馊>�~?cG��1����X�!�y���ț�;";�4�"�zFe�!R[�t����}Y�!*� b��&�c�A ��f��i���V1���akF�C��5�J�=7�,G�([���<�O!�q@� x�j�h=JU��ͶN!/��r�L b8<��UYCO_u ��`J�h��I�?G̕�����j��OPi�������HWmmU�����J�S��ғ�� �������@	�a���$_p��X#�Һ6���!{霚�j\��ب�Q�v�(oeK��(BQ��Ej��o͑�%�#�H}�BP�?�p0�B��:��tl
L��OH�g='f��U�[(��8)"�V���_8�竾��C}�O&�d��o��R&�p������ѭ:�d������2�#k"3�,�"p�@u�%u�C��.wu�(-�dZ6Y0���\�����A�!`͒r<�E���t�c�pX�*W�,jJ���gD)]r��m��`m��U2&��5Y��b�U�5_ᑪ|��Bj��k�
!�|���g�ր
P;Ţ*�T#����xX�b�/�Ns�E�n�D^��=�����r�y%�1�����A�E�wLc�M��K�TQʹ9,x�K%�1�'
���I�U�=
Jj3XW���A¸8��d�9tN�j��� v[����?�a�;�����np=��_.v���i�� �3�ޙے���(.)�;榮�?�6�X˵��>��r �ճ,zD�e��')?��P�o@,�I��Ͱ�n����V{!C�Я9�%)���b,�.ip&/u�(R�����iJg���Qe�rx���5RrD�V��`Ҍ�(�g��^b[��(�B�t�}]����Q�^��X�.`7��K!�9牫���΅M�4M��)	n��o�2�:����svl"�LLe��Ş'�e��ʬ8g�(%�R�X��q� 3���w��7W*�	-���������#rI]�{�1qFy`jR��W�����rnp�)�Bq2�p*�))� �xV�����13��.q�}O�R;?}�R2�y��81�#5��� A��d�v����n�`ձ>.m����e��Ftfy�6��+�߉wh� ��JF
ƺǯ�y����h�.�/�g-	Q
lW��7�0m-W����/;�@@��G" X�#�'�l�OXKq��h��g�d��Y&`�	�Z�Q<8*p�c��(������L_i!����*d�3`�ɇ�"ٟqU qj���w�_�4ה�%?�� �h�c´>o��*�i��'��G�h�"-�O)�<�G����-��bg�&��ͩӐ�<�d(��è�.�H��,8���Ɣ�錍�#����'�@�3'�d�!�3���B�v�1� �ᣮ���%�Qt�e"���lgZ`*d-����ɜ��F�"�[b�Gx2�ؤ�M�2��&�&ty�����Cr�(u�����G�Ƣ����EA�kמ�a�cI-Ԧ�$��c9��Ҏ
 x��E��-��pN������Q{ইy���is�
�8g�$YM"k����4��w������gJ*�Q��8�(�y�����Rl�Sq�a�/�rF�i��׻�OCć*=#z�5����;�R�����o��lT��?u�O��sL�T6���#d�9[`

��~J_T��<�$��l�
i@
�V� �~��Qn��fU6ȐbJ�'r׎K����wѳ��/�*�s�3D�V3`
	>�s��W��JCֱ!ꊀ��Q��._�`�S�ㄪ�Y�l�|�fϊ h��B��8˛�f0��[)AM��r�<JPM-��\K���:�O˝DD��y����M��Ԏ#Ae\��~��+R��mN# Ѱ*Xl>m�l	��b������@�95�\�YU�ouSL�$���T*$�.�[�޿lq��+����Y�<��4<�Qp ���iwrb|
���!�T�劶��"TH���e�9.�I�7���<��N��z �b���l��K_��ߴPW��k�a��,��	��l�ʪ����HQV��!9���c�Dx�5�'�4)1�˸]���XD��3�O���}&*�����O�J����
t�@�t]㨧�4\�u�$���,~�HiB`�ewi#�NlE�<<� �
�/P9|�͚ӌש���#�+�R�,=��NA#~Be��'����`6���v�񴥩��/����ťf�4?e8%߳<پ:>�1���OAU�'٣V*bF*b�M�)�=��'4� ��uW�p0�*pOV�/�"#>�� 6*D�����y{�gqFVM�c�߲+��D��\�ݭh�^�_��
�O9ة2� z�����rj��� �g�#��Жـ���^gċ����M����i�aVg[	S�Oo��,OtV�C
��8�8�{
��vA](e�-@��A6���X�_�L����"@�50�@�s*������!�*��8�{��c��ǹ���nT��Z�'ۣl"���}����� �+��E�m׭Q2K_Tt�]�q����RFLK���pІ��Y ��;��eo�E�dX#4�5�MKR�N�H?N�<����	_��}�?xds�Nr&+�RF��r�Y�1��Q�>0����(��憰9� �gg��&巔`��E��+l�煣꺒���Q�$`�i��z�W �c'�h��ѹ�I�Yp	إ$9K�� �9(�� �q�_�Kw�^�^4�>�Ӟ�Fy�������g�%��@��T������'Gwe��R�T�L��w@H���q`��u�͖�q@*U�tY,�yn�Ԝw���ޯ��Zq�g*~�����ª�(/����/Wݓ��:ꉈ�u�R7k��T�5`T���e�c�L6U�H\N��ΆQ�'����x-�08ٙ��Q$>l�ᔛ�����'ҫ�*^4�����S���+�2�D�T5�Zw+{Ym���9�6HA��n��&�\�i��RS ���ȫ�"�{� ��9��H�n6ۓ����Ş%�6�Z�tҦ�\���;�#j,���}�^Y�h47z��Q��� �_�9�I2Bjŭ�F*e[
�M	F2A��m��*uD��}�J��)���~�.�^&Fx=�=����X_�]/J�A!e\Λh]��UTC������V�)�,�[	8�*�҄P��R7y����^�U�� ��ŏGa��ViD��<�*�m�œ2�U0i�M���f�(��~@��9oY4�"���O��	3Y�z�8�Wj߸ݙ��6#,����Q�4 i!߯����^���x�À���6���E��*�G&�LP�<3�5 g2���H���)@?��y w��0ř[,�E>�|�X��%Ϻ'Nc=ȅ���V�<�T��6�����4cE}��׆d�Ai��D��EY,��jUc�?7u�%���:'z#G���#2�0t�hC�v��L�>�EȎ����qIT�\�]��J7�l�!��fD~F�7g��V����ɤ�c�C�L�}ʽۜ��a��M�U-u�^��ɎSZdf:��SBTQm�t}���ޣ�A,_�"�q�ڿL�HeFRx�BN�+}��$��׏�0y[Vg��NX�Ž�GUʱK �if�"u��5 �}-ڊӶ�ۮ�E G  ��C�v���� \��} �U~���g=�i�BY4�
@+U�2�9�SJ�� �{J�X&�3P�q���D R��YlV���^�+�ԄZCt��t2E�r� f��������+&��� ^{� ��d2M�� q�U)nl-�=>Ge~ꩃ�̘�\�d�;�z��</��ݖI�2X �H��\�i;;�i���w��E���W���S�\?�x��sY�Ҹi���-�������t�^ʉRg#��'%:�2�kJ&G�FA�-[��H ���`�}*C3�/��gW��k�";`�j9q�����]iB$]��t�i�#O�NR%�� VFg>g$8@t�np+S�<nd��z=���^P��U헢>=�KV�;�_�k��>�"S<'T�SNč��l)�^�*'%���V����f~�|��;���E/�V��ie��E!�٨ǵ����"a��Y�e��U˟>�(DRr���Eވ3���������b�r��/-��[3�^�S:(jֽU�n�9oxϩ*Jg�I��������}�]����$�� <�B��e�2d]&s�~�WC*� q:S�ɽ��~�O�z3v�q�u���&��8�b�zp6�a{�0
7�#t�E�lkX_
��^�m-�4�@�'='�Ps�<;Z��$ҡs��C�9@�Ӳ��.��f��xPِ6�ޒ>R`{�k]�`e/Li�r�a�Yf���+�}>ԏk3�c 
?C;�F��}��m��F�4n�����!��Y2I	��3g����[|�^��e���=)9�n\�J:_%��u�b#Ih}����(c.�"(��S���SX��M�-�"b���[
9���Yf/�1nt[���,��$[`� ;UU���h�a<�g���r��d�WJ���܇�⁻�́iE^cm���ND�*
�"��f�K*�oGxڸt�,e�BƘpM`4�����E��<�&a�ٔ��lE�4��4�apBx��mQ�	��.�#>bS�]e�N�� �W�(�H̩�fԺ���R(�4�ݾ ��3�d��4	�L��f=r=+nU��h����}.2�Xw���M-5����d�2 �6h�
����$�-s��lnn7϶�΁[��MôI+Wv���#'�P�^������\�+�灏n��-j���Ӏ{Ftr4(W���R��~�<���r�מ��b�[H����&B�HL�#]
�TD��ȩ]��s�Y�Ia;"�2����e1�g��M� 5��\Bw�`��&���e�Q����
^]��e���+��S�S$���n�*��u���M\�a��䳑��2�N���ߊp����Eg�Y�3,nz�*\���ͱNX�2㿣)����*O���N[$֊A�W���9�,�&��׸y�I��QAӺ�h�T3E.��~��gnXt9w��L��k~לK0��S�%��]�TwsT��|��������Ǉ[���&:,#��U����w�,	�h��m�_Y���G��~���r����!�>�a�g17����-3���'i���ذh�`,��i�d����`G&tQ(6�����S-pZ�3c����	 �l�-��D�<���a?��Q�z�9�HZ�c�t �9Y�U��aѭ��H���+�Zd`9��8���j�y�Ei\�gFj��]jn��E`� �\��e�gE I� <Ű\(��=��ʟ&E� ���A�*k_ĺB4�j�ĿQ嬇?^Ti˞7ѵ$$W��	x�9�o꾼�Ew9l��1��2�X�V�m��{�!�s ^���N�K�K�D�*�I��h���]=����	�2ٲ��\�bex���2���=H&�q�z	#�ȝ6���y�7ɂ��,��#�]�1Ji9.h@�FBHu#j���o:��k���)_�����J����r�	�6��ǂ{��I�Ӱ�-�`��p"䥌"bj��8���HU��H)��S�Z�0s,ō�{��IG�%������\�<�ɲ�y쯏/��p\^��YW{]�"�k�|��NU�@иOkc5�{�\�Y09
AU:W�,�H6�ɖC�lԛE��Te},�R�G�<��{�M����l�;�q�i�8Sl>t;����Ͳ/���|�e'�|�� �ϛd1e�"��Ë���)�§������Ⱦ�}�(i)` ���0�?�Ř��?��n87	e��v���4�˝ �"�8�C�"\)�ٸPHpq��e'��o���n��Q�n�+���d�8����e��/�2����W��'4hE�š���8[��w"
�.l��
C!��!%���p�~׀��|p3m�w2GS��R���>U(3���{�g��-w����n�����6�<~��������n~#L���<�-��p(^��$zY�)��'����Η��+�}>�g���l��� �-L���~ ��a�����dV]s�[��3�d��G3���\��ݳ*�Y T�ӥB���ÿe�dm@�$���5���4*������8;<R�n��ͽgl�����p��d�{K�fz�L(#��b��?\���m�|Vz�'aatn\	U�Zs�m�#�"Ͽ	�$�f�>��yw�JG�Y���K�e�F�iqO�d��?t�j�������,ӕT]��Y��sB�4�N�c��Ԯ�+B8(
�������NH�l��\y���抲�^�7?U9�?vS�XhQ=y[5ae��c����Ց�6V|���'	�O4˧�(�]IǺ��"t��̸�ʁ�Q����.����<vZV��+�z��j2gᗫGěd,r��)��2��˨aù	�}c��	-1@:JϜ���Ȋ5 ����/�cL�Nu�.w����E^NA�gY��Aj_9c�+�0�;8Zrj��J�js����A��}�_a�(}�?wY�*U,�������jݪR2$3�qA�=��ѺJ� f[�Thi��@ԁ����q�A�G��?�O� Y���8T���w�-U�P�YB{��u-&k�!��� �/.l���x�;�����J��-�ެwC? � � O�*����#�s^�
�"��~��(��ö�=.�?�_X�NJu��8��Z��~H4����l��/^�fOk@      z   �  x���Mn�@��է���~����L)"�Q�	!�X"!6�8G�$�g��lz[�*�����^�! y�}K�Z@� B���_�~���#����{G���i�c��zr��&$���ۗ���6$Y���M͚~g	FFR�E}��$�u�.p2�5m�0�y�8�8���p)] )F�!����y�me�.��ZZK�E{@���J�u��x��zT^�)|��6(=��
���S�i,G-]��%�o�:-�*��[����
ʇ�ԓ�P�k(D[.BE�ӆ�'�9�M��J�M��#���;���C) %��bQ� ��Vb4nj��T7�t�SM����9:}�&*�Y"�(j���pw}h�>R�%��E.�fA����������O�yb6U
�v����6��._uXҮ
{Bqhà���?�~� Nos��w�dai=���z#�T�@�Z����\j�S6&C�&�h�+Yબ��m"��T�8��x/��v���IJ�>7i�s�P���Y��	"YV��#z��!a��s�L���C+�K�N]��2;Cuc�����M��~��ߠ������A��?6��iNB5�\��6�(��;}�w�j��K���ןE�Ϊ���wN��y�,���ً8��^�8]��v,��W�`�n5q��b�a�iI��Git(�����>YT֟���"xh:dtO/�s���      s   b  x�eY�r�|��E�7u�a�4�����/P7���&e�{���;�P �yٝ��QWVVA��f���U?��uwP�V���y��'��J���,U7��;Z��ضQ��Z��J���t�۸�L=6���;�k{����$;O�ʪ�՝=v��n[7x�I�5>iT���?��I��S_~�n����ϵ��z���J�W�9�Cc�/{�U���Z���j�eh6V�c_�ϓ�\�*51���M�;7�9ɹ�U^
H'�j74���G{j���ISU�������v���lD��~h���^���a:����}<M��<)��4[�3uc�UO�0����T�B/���q�HX�3�SR��,ᅺ��pP?���c˂�aTQ/�%�sx�s�*��#LE���/�ΐ)���� ���օ)\����k��v��_���nP���֢������;���~pe8/�t��4{�z�􇃜�q����K�z�椮�~�T��QMQ
v�Fd��Q>DH��B$�L}i�O��;dA߿hJ�Rf�s���vp ,݈Ȕm���n���a�`���ǋ< KuیV]�m�t�d,�+��xB��瓇��f�� ��b�ؽ��w���rŚ��y�u�6#�qk?8�؇�|H&����,������=؝P��Y�#��#N�d�w#~_��H0W�9� xV.��	
�[;�KK�&�*ϗ�\��5m��й�L�ao�	G)�g�fwS� ]Pxac�2�D��}�]9Q&S3��� ����ߣ�BXRQ��h�~��=�[�d��}2���L�����uD��g�'�I�5/`�������9WjE�2�5Ҳێ�7}�
�Y�0\�"�P����������& 3
�0S'A�R���oPk�mSD����x���9-]�:TN4�l�V��4t&H7Y�ÿ�fۨ�aCw,�5.� �`��G�ݒ5�D�%y�*PD�{����2���Ђ�Ӌn;8;w#�((�	���hS��_�7Д�ql����܈ĸj��=0������t�k��H��0}N2��0��gQ�|�K�H9�h��;�n�wД��	�/Ƚ����1[��Pk��y�%�}�7��d����Ȫ���i����t]�IU��q�|u���)�5Gf�>�����|�}k���_t�h����&a:G6.O-���N�E)�kΑ��D��D�Uʑ/��W�(3����trC����"S�
L��C���e�-�� �=$?��K�,6^x�zQ���D�h��)�k�q�䝒���f.6F.KM&k���x��D�9ENs6j�=pN	��6Pt.r4aZH"�T	�e��S?�ǁ��K�3��TB4�w���=�O-��`P,�*U��7�0�X���(N������� ��1'
0�L��K�?K��R�*�}U� >�lpM�_�W����=��� ��AU(��+��o�s4}����>'���<��+?�b�E1Q�9�3ņR"��Yh/[gM�����w�,b1
�X�i�}I_��>\<�O5�����$��WKRiٲ+�u它 @��b�n�E�.~����~��Q�p�F�,�Ehwv�%�p��2%5�-l�m]�ْ�D`�TCu�8i���tV�u��?x�
��O<#	7A�W�]h2��Tv_>+Z�āT�_�Дq�I�d����I�K*���΋�I!� (p�M�E�h33-a2j�Х�P��B�4���(n��q���ъ�(ɬld����O[9�ɗ��8qbz�0!�{*�B���q�44�rGE���������(V3ma�η�"R��F�w��\��qLwz6��$��Rp�G*��IB�]=:d��>|�N�@��.��cK� ��C+N��2�(�;PKh6o���Q ��V�<2�/�G���	���
���J���m���ex3@��19\ێXVЅ�i��V�6z��{y`�O�bt]<���^׿F~=pc�k���/��BX�]'�c,c���iɣ�|��0���cB�H+o��9ó����7��y�Ȕq��/b�h��ƫRj�[Ǭ�4��Bx�9���2��%M5���A�-�>Ji3�l��N���:��һ�_3���� �6�cP��l��2��$����X�.���M��9@
�D�O]G��q�苵��@��ٷ|E4���`�aW�李�i�d_�\��ə�i�%��׸I �_��z��1+6u�o�q@��cx�pZ hq&����S?�p��w���<j��a?P���'9���2�P?-�˾?L��t����&5D͞�+pa�g@Z�~PŅ�ו�9U�j���T)}��
Ş�od���6Q��G�b�k��|<҇1c�3!Qh�����9q9n1���$�d[�ܕ���8L��0�.TP�G���4	kx禇I��h���c+^M��
_�Y\^"�d�ŔK1�hg�q_!]�~�M��Vg��;��J�,	k�X�2Z���K�:�*7*�|��ֶkF��H7��rM��l�S���pR��i�9������0�VB��g*��R"_���VN�j�¸"w�(�2�c�4�n�d�^���b�\�,$DU�����،��O�]�������RH1$+4�-R q����J"�u��bB}��<����KYXϖ<��� 0^���bu��M�Co츧=�<m�4lz�]F�t�ڮ'?�}:$����6~��a�R��:�P^G��4{��a-^�eKK��6t�<R
�}9��YkD/!s�5��Vn�KU�y<�H#�8���"���K�Z�f�=A�����Z��W�q�!���w��$��H�dR��#>I�:�g�#
*��~�;����]�Hu�����8����	�$UjuA��RYמS4/C�o�i '�pĿ~�n
b����2�b�,��4�]J�`�'�JmzR2��_ж��_�ym=9��]�9i	�"ڼ�������/2����_Tqm��屡*�؂y�)k$7��lB�ɼ��G�y)Mx� �w14�:ʖ�.U"��/c��*�,_s���9��v>��¥1�7+�J%�߈��s��ò�#�
�N�cd�ɓP:��*�!�S[~802�g�ƪb�,�,?'�~f��*��'���#��w�X!�ĝX�'��$X�'1b�V�<4=���3���2T�J��󀙖����kJP���rʿ���/�ĥ&�ؕƩS^!��G?�YQ��KWm��Dm7�s�h�W���=8�OpWY�&}����a 5F������<V�Ⓘ;�B3�)�Z�v�?��R:,Q�tm��WM]����.���c�)����4�Oh�\������c�B+�����^�S&�ikU�FK��e?�K$������ ��iܗ�:y𨪔��cT_�{�zyTZ��
�CZ�ceT�ɸQ&3t�t5��UN32�������|(~wa�SR�*�TQ�m6��'�Fpͣ�����P=�3���e�О�=���Io�l�-o�I[N������C����,�FS�%%X͞oU��v������p��RZ{�;JTD����?{�2�V�\�2����浦�.�E�2~#R�3h�mV?)���Z� �J����@0:��h|����:�����Z ]��{/pS�z���S�޿,	��l��ςj�=+�q�q�����p3�j�n��=��4��q�������s�A�      j   C   x�+�I,��+��44�J��I�44�*��)K-�4�J*�ϫJ�4��ˏ�M�MJ-*��,�4������ <u      v   _  x��XY�7����Dj�K��$�b�N>r��V��dϟ�RKb��"%A4��Do��a�����埧��t-���~}x{��������o=9�c�?�7��|���1�< ���2�a~�����緿_�%e�o���o�����t���i�:��a|�����ߧsA[���6�a�,P���!qUƐ@��=�M��0q����@�<zZ!q����@J¼�u�sH#橑F�e8a�v�����Ϸ(���������"p��|��<��Z���� �+6 ��I�N"��<7h� �� �_����:���'l�ï.��><�k4�F�g2�p0��ƀ������8x����8��0�=��y����1�@�;3b����nQ��+1*�
W��ܧ�;�[L�-'��'�bYEz`���6�����p��Q��I�`�%���AW���	�H攴�<��`�C:<����4̬�>�sO��H�L2$�vJ��´�-�ǏPog6�.��{)I�hF���]f�ز�$\������H��j�;5��!��	#9jLnpU��n6���Wv�&�@*(ؿ�ǂ�5�(vٯğs�u8t�p �Z"P�E)��6����+�4BOn6p(��zw�*�ZӨx���Y��e_�TJ5��k��M#մ�o�����C��N�bAcXf�e��<��u ��.���1��aX7�r�4�(x,�<Bx����$�n�����i��fq]�a���*���L3զ�\��p�����R�ȃr���a8&.�.���9*��L���$=�iÑi��<
��wd��Ȫݕ��	�.G�1�\��ޝ�!�MкⒸ��Q`�L��Lޖ�:��H�r�ñ��J�������	K/����������
&쒴�G�Rs0#k�Q�
�dROp�g�����f�(`S\R���t�7dTaDCk��Z��A�U}�G���V��	F���u|U���'8s����#�8m�k��8��{;U ӮsV5��Q�3�0:/���F�r��%��m[(���2�]�T�
�a���Z�	6V�b�4��C$0�,"'�F��$�Q GP�.K�At�ktD���IZ7qK\�m!:zn�&�*�l:�&�G�eY Db����J�+����62N.�O��������U��.�`e=��aړ���Jf�r������rj�X����ɊJY}��4�;P���PN�pK(�9w�&��SV6q��w�~��*�8�84�@h�B���csW�5ҥt�l�l,%�@4W X��H3C��p�#\��8��Dz�kz/.�-�l�qS�i����>f9����e��t|�����0�9y(,��1VO��譸7���X�����>��������l<��ke���	WwUʐ� %�.�Q)�[1�������q�DJ��-��'��ed��m�>!�����&ʎ�Z"m̗�
�9M�D��d#��UW^���g�����M���&��\nl!eӌk;0��\W�>2�OӶ��=�qBۣ��L*ϵP�e���(��C�Ⱦ�Fڋ��|8���MSů-�ƚ���b������w������'���     