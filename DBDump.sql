--CREATE database KLMPOSDB tablespace pg_Default;

DO $$ DECLARE
    tabname RECORD;
BEGIN
    FOR tabname IN (SELECT tablename 
                    FROM pg_tables 
                    WHERE schemaname = current_schema()) 
LOOP
    EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(tabname.tablename) || ' CASCADE';
END LOOP;
END $$;


CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE TYPE gender_datatype AS ENUM ('F', 'M','T');
SET datestyle = dmy;

--drop table if exists public.stateDefinition;
CREATE TABLE public.stateDefinition (
	stategroup character varying(28),
	stateid integer,
    statename    character varying(28),
    uniqueid UUID default uuid_generate_v4(),
    creationdate date default current_timestamp,
    lastmodified date default current_timestamp,
    CONSTRAINT stateDefinition_pk PRIMARY KEY (uniqueid)
);

insert into statedefinition(stategroup,stateid,statename) values('OrderStatus',1,'new');
insert into statedefinition(stategroup,stateid,statename) values('OrderStatus',2,'pending');
insert into statedefinition(stategroup,stateid,statename) values('OrderStatus',3,'created');
insert into statedefinition(stategroup,stateid,statename) values('OrderStatus',4,'cancelled');
insert into statedefinition(stategroup,stateid,statename) values('OrderStatus',5,'rejected');
insert into statedefinition(stategroup,stateid,statename) values('OrderStatus',6,'returned');
insert into statedefinition(stategroup,stateid,statename) values('UserStatus',1,'active');
insert into statedefinition(stategroup,stateid,statename) values('UserStatus',2,'inactive');
insert into statedefinition(stategroup,stateid,statename) values('UserStatus',3,'disabled');
insert into statedefinition(stategroup,stateid,statename) values('DeliverySlipStatus',1,'new');
insert into statedefinition(stategroup,stateid,statename) values('DeliverySlipStatus',2,'order_created');
insert into statedefinition(stategroup,stateid,statename) values('DeliverySlipStatus',3,'noorder_created');
insert into statedefinition(stategroup,stateid,statename) values('UserGroupStatus',1,'active');
insert into statedefinition(stategroup,stateid,statename) values('UserGroupStatus',2,'inactive');    
insert into statedefinition(stategroup,stateid,statename) values('CategoryStatus',1,'active');
insert into statedefinition(stategroup,stateid,statename) values('CategoryStatus',2,'inactive'); 

--drop table if exists public.domaindata;

CREATE TABLE public.domaindata (
	domainname character varying(28) constraint domaindata_UQ unique,
	description character varying(256),
    uniqueid UUID default uuid_generate_v4(), 
    creationdate date default current_timestamp,
    lastmodified date default current_timestamp,
    CONSTRAINT domaindata_pk PRIMARY KEY (uniqueid)
);

insert into domaindata(domainname,description) values('textile','kalamandir textile division');
insert into domaindata(domainname,description) values('retail','kalamandir retail division');
insert into domaindata(domainname,description) values('EE','kalamandir Electrical Electronics organization');

--drop table if exists public.paymentMethod;
CREATE TABLE public.paymentMethod (
    paymentMethodID integer ,
    paymentMethodName character varying(100),
    paymentMethodDescription    character varying(255),
    uniqueID UUID default uuid_generate_v4() , 
    creationdate date default current_timestamp,
    lastmodified date default current_timestamp,
    CONSTRAINT paymentMethod_pk PRIMARY KEY (uniqueid)
);


--drop table if exists public.userType;
CREATE TABLE public.userType (
    typeID integer primary key,
    typeDescription    character varying(28),
    creationdate date default current_timestamp,
    lastmodified date default current_timestamp
);

insert into userType(typeID,typeDescription) values(0,'anonymous user/customer');
insert into userType(typeID,typeDescription) values(1,'super admin');
insert into userType(typeID,typeDescription) values(2,'admin');
insert into userType(typeID,typeDescription) values(3,'manager');    
insert into userType(typeID,typeDescription) values(4,'cashier');
insert into userType(typeID,typeDescription) values(5,'salesExecutive');
insert into userType(typeID,typeDescription) values(6,'salesMan');
insert into userType(typeID,typeDescription) values(7,'security');
insert into userType(typeID,typeDescription) values(17,'customised');


--drop table if exists public.userData;
CREATE TABLE public.userData (
	userName character varying(28),
	password character(100),
	status integer,
	phonenumber integer,
    gender gender_datatype,
    type integer references userType(typeID),
    dateofbirth date,
    email character varying(100),
	domaindatauuid UUID references domaindata(uniqueID) ,
    uniqueID UUID default uuid_generate_v4() , 
    creationdate date default current_timestamp,
    lastmodified date default current_timestamp,
    CONSTRAINT userData_pk PRIMARY KEY (uniqueid)
);

insert into public.userdata(userName,password,status,phonenumber,gender,type,dateofbirth,email,domaindatauuid)
  values ('bhaskara','ilovedatabase',1,'55555555','M',6,
  '28-10-1980','bhaskara.bangaru@otsi.co.in',(select uniqueid from domaindata where domainname='textile'));

insert into public.userdata(userName,password,status,phonenumber,gender,type,dateofbirth,email,domaindatauuid)
  values ('niranjan','ilovemgmt',1,'66666666','M',1,
  '28-10-1980','bhaskara.bangaru@otsi.co.in',(select uniqueid from domaindata where domainname='retail'));

  

--drop table if exists public.userData_av;
CREATE TABLE public.userdata_av (
    id serial NOT NULL,
	ownerid UUID references userdata(uniqueID),
	type integer,
	name character varying(128),
	intvalue integer,
	stringvalue character varying(128),
	datevalue character varying(128),
	lastmodified timestamp default current_timestamp
  );


insert into userdata_av(id,ownerid,type,name,datevalue)
values
(1,(select uniqueid from userdata where username='niranjan'),3,'lastvisited',current_timestamp);

insert into userdata_av(id,ownerid,type,name,stringvalue)
values
(2,(select uniqueid from userdata where username='bhaskara'),3,'password','neerajchopra');


--drop table if exists stores;
CREATE TABLE public.stores (
    storeName character varying(28),
    StoreDescription character varying(200),
    uniqueid UUID default uuid_generate_v4() ,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp,
    CONSTRAINT stores_pk PRIMARY KEY (uniqueid)
);

--drop table if exists public.userStoreAssignment;
CREATE TABLE public.userStoreAssignment (
    userUUID UUID references userData(uniqueID),
    storeUUID UUID references Stores(uniqueID),
    creationdate date default current_timestamp,
    lastmodified date default current_timestamp
);


CREATE TABLE public.order_data (
    orderNumber character varying(28),
    status integer, 
    grossvalue decimal(12,2),
    taxcode character(28),
    taxvalue decimal(12,2),
    netvalue decimal(12,2),
    storeUUID UUID references Stores(uniqueID),
    customerid UUID  references userdata(uniqueID),
    domaindatauuid UUID  references domaindata(uniqueID),
    uniqueID UUID default uuid_generate_v4(),
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp,
    CONSTRAINT order_pk PRIMARY KEY (uniqueid)
);

--drop table if exists deliveryslip;
CREATE TABLE public.deliveryslip (
	dsNumber character varying(28),
	status integer,
	salesManID UUID references userdata(uniqueID),
	orderid UUID references order_data(uniqueID),
    uniqueID UUID default uuid_generate_v4() ,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp,
    CONSTRAINT deliveryslip_pk PRIMARY KEY (uniqueid)
);


insert into deliveryslip(dsNumber,status,salesManID) values ('ds00001',1,(select uniqueID from userdata where username='bhaskara'));
insert into deliveryslip(dsNumber,status,salesManID) values ('ds00002',1,(select uniqueID from userdata where username='bhaskara'));
insert into deliveryslip(dsNumber,status,salesManID) values ('ds00003',1,(select uniqueID from userdata where username='bhaskara'));


--drop table if exists public.catalog_categories;
CREATE TABLE public.catalog_categories (
    id serial NOT NULL,
    name character varying(128),
    description character varying(256),
    status integer,
    parentCategoryid UUID,
    uniqueid UUID default uuid_generate_v4() ,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp,
    CONSTRAINT catalog_categories_pk PRIMARY KEY (uniqueid)
  );


insert into catalog_categories (name,description,status,parentCategoryid) values ('LADIES','Main Category',1,NULL);

insert into catalog_categories (name,description,status,parentCategoryid) values ('DHOTIS','Sub Category',1,(select uniqueID from catalog_categories where name='LADIES'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('PATTU','Sub Category',1,(select uniqueID from catalog_categories where name='LADIES'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('WESTERN WEAR','Sub Category',1,(select uniqueID from catalog_categories where name='LADIES'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('SAREES-LF','Sub Category',1,(select uniqueID from catalog_categories where name='LADIES'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('SAREES-VF','Sub Category',1,(select uniqueID from catalog_categories where name='LADIES'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('DRESS MATERIAL','Sub Category',1,(select uniqueID from catalog_categories where name='LADIES'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('READYMADES','Sub Category',1,(select uniqueID from catalog_categories where name='LADIES'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('BOTTOMS','Sub Category',1,(select uniqueID from catalog_categories where name='LADIES'));

insert into catalog_categories (name,description,status,parentCategoryid) values ('COTTON','LEAF Category',1,(select uniqueID from catalog_categories where name='SAREES-LF'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('DUPN WVNG','LEAF Category',1,(select uniqueID from catalog_categories where name='SAREES-LF'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('WRK','LEAF Category',1,(select uniqueID from catalog_categories where name='SAREES-LF'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('SYN LR','LEAF Category',1,(select uniqueID from catalog_categories where name='SAREES-LF'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('FNC WRK','LEAF Category',1,(select uniqueID from catalog_categories where name='SAREES-LF'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('B COTN','LEAF Category',1,(select uniqueID from catalog_categories where name='SAREES-LF'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('SYN MR','LEAF Category',1,(select uniqueID from catalog_categories where name='SAREES-LF'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('SICO PRT','LEAF Category',1,(select uniqueID from catalog_categories where name='SAREES-LF'));
insert into catalog_categories (name,description,status,parentCategoryid) values ('IK PRT','LEAF Category',1,(select uniqueID from catalog_categories where name='SAREES-LF'));



CREATE TABLE public.barcode
(
	defaultcatalogcategoryid UUID references catalog_categories(uniqueid),
    barcode Character default uuid_generate_v4() primary key,
    attr_1 varchar(255) NULL,
    attr_2 varchar(255) NULL,
    attr_3 varchar(255) NULL,
    attr_4 varchar(255) NULL,
    attr_5 varchar(255) NULL,
    attr_6 varchar(255) NULL,
    attr_7 varchar(255) NULL,
    attr_8 varchar(255) NULL,
    attr_9 varchar(255) NULL,
    attr_10 varchar(255) NULL,
    attr_11 varchar(255) NULL,
    attr_12 varchar(255) NULL,
    attr_13 varchar(255) NULL,
    attr_14 varchar(255) NULL,
    attr_15 varchar(255) NULL,
    attr_16 varchar(255) NULL,
    attr_17 varchar(255) NULL,
    attr_18 varchar(255) NULL,
    attr_19 varchar(255) NULL,
    attr_20 text NULL,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);

--drop table if exists productItem;

CREATE TABLE public.productItem (
    id serial NOT NULL,
    barcode Character  references barcode(barcode), 
    typecode  character varying(28),    
    defaultimage  character varying(28), 
    stock integer,
    status integer,
    name character varying(512),
    costprice decimal(12,2),
    listprice decimal(12,2),
    UOM character varying(28),
    storeuuid UUID references stores(uniqueID),
    domaindatauuid UUID references domaindata(uniqueID),
    uniqueid UUID default uuid_generate_v4() ,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp,
    CONSTRAINT productItem_pk PRIMARY KEY (uniqueid)
);


--drop table if exists productItem_av;
CREATE TABLE public.productItem_av (
    ownerid UUID references productItem(uniqueID),
    type integer,
    name character varying(128),
    intvalue integer,
    stringvalue character varying(128),
    datevalue character varying(128),
    lastmodified timestamp default current_timestamp
);


CREATE TABLE public.productInventory
(
    productuuid  UUID references ProductItem(uniqueid),
    stockvalue integer,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);


CREATE TABLE public.productImage
(
    productuuid   UUID references ProductItem(uniqueid),
    image character,
    uniqueid UUID default uuid_generate_v4(),
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp,
    CONSTRAINT productImage_pk PRIMARY KEY (uniqueid)
);


/*created the barcode table 01-10-2021*/
/*when saving user will send the default uniqueUUID*/




CREATE TABLE public.pos_inventories (
    id serial4 NOT NULL,
    barcode varchar(255) NOT NULL,
    attr_1 varchar(255) NULL,
    attr_2 varchar(255) NULL,
    attr_3 varchar(255) NULL,
    attr_4 varchar(255) NULL,
    attr_5 varchar(255) NULL,
    attr_6 varchar(255) NULL,
    attr_7 varchar(255) NULL,
    attr_8 varchar(255) NULL,
    attr_9 varchar(255) NULL,
    attr_10 varchar(255) NULL,
    attr_11 varchar(255) NULL,
    attr_12 varchar(255) NULL,
    attr_13 varchar(255) NULL,
    attr_14 varchar(255) NULL,
    attr_15 varchar(255) NULL,
    attr_16 varchar(255) NULL,
    attr_17 varchar(255) NULL,
    attr_18 varchar(255) NULL,
    attr_19 varchar(255) NULL,
    attr_20 text NULL,
    parent_barcode varchar(255) NULL,
    cost_price numeric(15, 2) NOT NULL,
    item_mrp numeric(15, 2) NOT NULL,
    item_rsp numeric(15, 2) NOT NULL,
    to_store_id int4 NOT NULL,
    promo_label varchar(255) NULL,
    created_at timestamp(6) NULL,
    updated_at timestamp(6) NULL,
    uom varchar(255) NOT NULL DEFAULT 'units'::character varying,
    pos_hsn_master_id int4 NOT NULL DEFAULT 0,
    original_barcode varchar(255) NULL,
    original_barcode_created_at timestamp(6) NULL,
    create_for_location int4 NULL DEFAULT 0,
    value_addition_cp numeric(15, 2) NULL DEFAULT 0,
    item_code varchar(255) NULL,
    item_sku varchar(255) NULL,
    attr_21 varchar(255) NULL,
    attr_22 varchar(255) NULL,
    attr_23 varchar(255) NULL,
    attr_24 varchar(255) NULL,
    attr_25 varchar(255) NULL
  );
  
--drop table if exists lineitems;
CREATE TABLE public.Lineitems (
	dsuuid UUID references deliveryslip(uniqueID),
	itemsku  UUID references ProductItem(uniqueID), 
	itemprice decimal(12,2),
	quantity integer,
	grossvalue decimal(12,2),
	discount decimal(12,2),
	netvalue decimal(12,2),
    uniqueid UUID default uuid_generate_v4() ,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp,
    CONSTRAINT lineitems_pk PRIMARY KEY (uniqueid)
);


--drop table if exists lineitems_re;
CREATE TABLE public.Lineitems_re (
	itemsku UUID references ProductItem(uniqueID),
	itemprice decimal(12,2),
	quantity integer,
	grossvalue decimal(12,2),
	discount decimal(12,2),
	netvalue decimal(12,2),
	orderid UUID references order_data(uniqueid),
    uniqueid UUID default uuid_generate_v4() ,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp,
    CONSTRAINT lineitems_re_pk PRIMARY KEY (uniqueid)
);


--drop table if exists promotion;
CREATE TABLE public.promotion (
    PromotionID character varying(28),
    startdate timestamp default current_timestamp,
    enddate timestamp ,
    rank integer,
    enabledflag integer,
    availableflag integer,
    uniqueid UUID default uuid_generate_v4() ,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp,
    CONSTRAINT promotion_pk PRIMARY KEY (uniqueid)
);

--drop table if exists promotion_av;
CREATE TABLE public.promotion_av (
    ownerid UUID references promotion(uniqueID),
    type integer,
    name character varying(128),
    intvalue integer,
    stringvalue character varying(128),
    datevalue character varying(128),
    lastmodified timestamp default current_timestamp
);


--drop table if exists PromotionStoreAssignment;                 

CREATE TABLE public.PromotionStoreAssignment (                                      
     PromotionUUID UUID references promotion(uniqueID),
     StoreUUID UUID references Stores(uniqueID)
    );

--drop table if exists PoolConditionRules;
CREATE TABLE public.PoolConditionRules (
    ruleID character varying(28),
    columnName character varying(28),
    operator character varying(28) ,
    values character varying(28) ,
    uniqueid UUID default uuid_generate_v4(),
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp,
    CONSTRAINT PoolConditionRules_pk PRIMARY KEY (uniqueid)
);

--drop table if exists PromotionPoolAssignment;

CREATE TABLE public.PromotionPoolAssignment (
      PromotionUUID UUID references promotion(uniqueID),
      PoolUUID UUID references PoolConditionRules(uniqueID)
    );
-- reference table pool to PoolConditionRules
--drop table if exists PromotionDSAssignment;

CREATE TABLE public.PromotionDSAssignment (
    PromotionUUID UUID references promotion(uniqueID),
    dsuuid UUID references deliveryslip(uniqueID)
    );





--drop table if exists PromoCondtion_Pool;

CREATE TABLE public.PromoCondtion_Pool (
    poolName character varying(28),
    poolType timestamp default current_timestamp,
    ruleUUID UUID references PoolConditionRules(uniqueID),
    enabledflag integer,
    uniqueid UUID default uuid_generate_v4() primary key,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);


--drop table if exists giftVoucher;
CREATE TABLE public.giftVoucher (
    GiftVoucherID serial NOT NULL,
    GiftVoucherNumber integer,
    Description character varying(28),
    ExpiryDate timestamp default current_timestamp,
    TotalGVAmount decimal(12,2),
    UsedAmount decimal(12,2),
    userUUID UUID references userData(uniqueID),
    uniqueid UUID default uuid_generate_v4() ,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp,
    CONSTRAINT giftVoucher_pk PRIMARY KEY (uniqueid)
);

drop SEQUENCE tax_tax_id_seq;

CREATE SEQUENCE tax_tax_id_seq START 101;

drop SEQUENCE hsn_details_hsn_id_seq;

CREATE SEQUENCE hsn_details_hsn_id_seq START 101;

drop SEQUENCE slab_id_seq;

CREATE SEQUENCE slab_id_seq START 101;

CREATE TABLE public.tax
(
    tax_id bigint NOT NULL DEFAULT nextval('tax_tax_id_seq'::regclass),
    cess real,
    cgst real,
    igst real,
    sgst real,
    tax_label character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT tax_pkey PRIMARY KEY (tax_id)
);
                   
CREATE TABLE public.hsn_details
(
    hsn_id bigint NOT NULL DEFAULT nextval('hsn_details_hsn_id_seq'::regclass),
    decsription character varying(255) COLLATE pg_catalog."default",
    hsn_code character varying(255) COLLATE pg_catalog."default",
    is_slab_based boolean,
    tax_applies_on character varying(255) COLLATE pg_catalog."default",
    tax_id bigint,
    CONSTRAINT hsn_details_pkey PRIMARY KEY (hsn_id),
    CONSTRAINT fkk6122lsn606aqakw9rkpjjr0f FOREIGN KEY (tax_id)
        REFERENCES public.tax (tax_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);


CREATE TABLE public.slab
(
    id bigint NOT NULL DEFAULT nextval('slab_id_seq'::regclass),
    price_from double precision,
    price_to double precision,
    hsn_id bigint,
    tax_id bigint,
    CONSTRAINT slab_pkey PRIMARY KEY (id),
    CONSTRAINT fkafy1tnr6yqgkdc6vxxdfnm8ac FOREIGN KEY (tax_id)
        REFERENCES public.tax (tax_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fksrb2pbo42kftihvosebfxxcxs FOREIGN KEY (hsn_id)
        REFERENCES public.hsn_details (hsn_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

CREATE TABLE public.barcode_textile
(
    barcode Character default uuid_generate_v4() primary key,
    attr_1 varchar(255) NULL,
    attr_2 varchar(255) NULL,
    attr_3 varchar(255) NULL,
    attr_4 varchar(255) NULL,
    attr_5 varchar(255) NULL,
    attr_6 varchar(255) NULL,
    attr_7 varchar(255) NULL,
    attr_8 varchar(255) NULL,
    attr_9 varchar(255) NULL,
    attr_10 varchar(255) NULL,
    attr_11 varchar(255) NULL,
    attr_12 varchar(255) NULL,
    attr_13 varchar(255) NULL,
    attr_14 varchar(255) NULL,
    attr_15 varchar(255) NULL,
    attr_16 varchar(255) NULL,
    attr_17 varchar(255) NULL,
    attr_18 varchar(255) NULL,
    attr_19 varchar(255) NULL,
    attr_20 text NULL,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);


--drop table if exists product_textile;
CREATE TABLE public.product_textile (
    id serial4 NOT NULL,
    barcode varchar(255) references Barcode_textile(barcode),
    parent_barcode varchar(255) NULL,
    cost_price numeric(15, 2) NOT NULL,
    item_mrp numeric(15, 2) NOT NULL,
    item_rsp numeric(15, 2) NOT NULL,
    to_store_id int4 NOT NULL,
    promo_label varchar(255) NULL,
    created_at timestamp(6) NULL,
    updated_at timestamp(6) NULL,
    uom varchar(255) NOT NULL DEFAULT 'units'::character varying,
    pos_hsn_master_id int4 NOT NULL DEFAULT 0,
    original_barcode varchar(255) NULL,
    original_barcode_created_at timestamp(6) NULL,
    create_for_location int4 NULL DEFAULT 0,
    value_addition_cp numeric(15, 2) NULL DEFAULT 0,
    item_code varchar(255) NULL,
    item_sku varchar(255) NULL,
    attr_21 varchar(255) NULL,
    attr_22 varchar(255) NULL,
    attr_23 varchar(255) NULL,
    attr_24 varchar(255) NULL,
    attr_25 varchar(255) NULL
  );