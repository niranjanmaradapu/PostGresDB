--CREATE database KLMPOSDB tablespace pg_Default;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE TYPE gender_datatype AS ENUM ('F', 'M','T');

drop table if exists public.stateDefinition;
CREATE TABLE public.stateDefinition (
	stategroup character varying(28),
	stateid integer,
    statename    character varying(28),
    uniqueid UUID default uuid_generate_v4() primary key,
    creationdate date default current_timestamp,
    lastmodified date default current_timestamp
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

drop table if exists public.domaindata;

CREATE TABLE public.domaindata (
	domainname character varying(28) constraint domaindata_UQ unique,
	description character varying(256),
    uniqueid UUID default uuid_generate_v4() primary key, 
    creationdate date default current_timestamp,
    lastmodified date default current_timestamp
);

insert into domaindata(domainname,description) values('textile','kalamandir textile division');
insert into domaindata(domainname,description) values('retail','kalamandir retail division');
insert into domaindata(domainname,description) values('EE','kalamandir Electrical Electronics organization');

anonymous / application

customer(buyer)/user(KM employee)


drop table if exists public.userType;
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



drop table if exists public.userData;
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
    uniqueID UUID default uuid_generate_v4() primary key, 
    creationdate date default current_timestamp,
    lastmodified date default current_timestamp
);

insert into public.userdata(userName,password,status,phonenumber,gender,type,dateofbirth,email,domaindatauuid)
  values ('bhaskara','ilovedatabase',1,'55555555','M',6,
  '28-10-1980','bhaskara.bangaru@otsi.co.in',(select uniqueid from domaindata where domainname='textile'));

insert into public.userdata(userName,password,status,phonenumber,gender,type,dateofbirth,email,domaindatauuid)
  values ('niranjan','ilovemgmt',1,'66666666','M',1,
  '28-10-1980','bhaskara.bangaru@otsi.co.in',(select uniqueid from domaindata where domainname='retail'));

  

drop table if exists public.userData_av;
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
((select uniqueid from userdata where username='niranjan'),3,'lastvisited',current_timestamp);

insert into userdata_av(id,ownerid,type,name,stringvalue)
values
((select uniqueid from userdata where username='bhaskara'),3,'password','neerajchopra');

/* these are originally discussed designed tables, but not required as introduced lookup table userType

drop table if exists public.userGroup;
CREATE TABLE public.userGroup (
    id serial NOT NULL,
    groupName character varying(128),
    groupDescription character varying(256),
    status integer,
    uniqueID UUID default uuid_generate_v4() primary key, 
    creationdate date default current_timestamp,
    lastmodified date default current_timestamp
  );

drop table if exists public.userGroupUserAssignment;
CREATE TABLE public.userGroupUserAssignment (
    userUUID UUID references userdata(uniqueID),
    userGroupUUID UUID references userGroup(uniqueID)
    );

drop table if exists public.userRole
CREATE TABLE public.userRole (
    id serial NOT NULL,
    roleName character varying(128),
    roleDescription character varying(256),
    status integer,
    uniqueID UUID default uuid_generate_v4() primary key, 
    creationdate date default current_timestamp,
    lastmodified date default current_timestamp
  );


drop table if exists public.userRoleUserAssignment;
CREATE TABLE public.userRoleUserAssignment (
    userUUID UUID references userData(uniqueID),
    userRoleUUID UUID references userRole(uniqueID)
    );

*/     

drop table if exists deliveryslip;

CREATE TABLE public.deliveryslip (
	dsNumber character varying(28),
	status integer,
	salesManID UUID references userdata(uniqueID),
    uniqueID UUID default uuid_generate_v4() primary key,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);

insert into deliveryslip(dsNumber,status,salesManID) values ('ds00001',1,(select uniqueID from userdata where username='bhaskara'));
insert into deliveryslip(dsNumber,status,salesManID) values ('ds00002',1,(select uniqueID from userdata where username='bhaskara'));
insert into deliveryslip(dsNumber,status,salesManID) values ('ds00003',1,(select uniqueID from userdata where username='bhaskara'));

drop table if exists lineitems;
CREATE TABLE public.Lineitems (
	dsuuid UUID references deliveryslip(uniqueID),
	itemsku character varying(28),
	itemprice decimal(12,2),
	quantity integer,
	grossvalue decimal(12,2),
	discount decimal(12,2),
	netvalue decimal(12,2),
    uniqueid UUID default uuid_generate_v4() primary key,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);

insert into lineitems(dsuuid,itemsku,itemprice,quantity,grossvalue,discount,netvalue)
values
((select uniqueID from deliveryslip where dsNumber='ds00001'),'I000001',999.00,2,1998.00,0,1998.00 );

insert into lineitems(dsuuid,itemsku,itemprice,quantity,grossvalue,discount,netvalue)
values
((select uniqueID from deliveryslip where dsNumber='ds00002'),'I000002',599.00,3,1797.00,0,1797.00 );



drop table if exists stores;
CREATE TABLE public.stores (
    storeName character varying(28),
    StoreDescription character varying(200),
    uniqueid UUID default uuid_generate_v4() primary key,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);

1. status inclusion
2. domain inclusion
3. location

sample data insert statements



drop table if exists promotion;
CREATE TABLE public.promotion (
    PromotionID character varying(28),
    startdate timestamp default current_timestamp,
    enddate timestamp ,
    rank integer,
    enabledflag integer,
    availableflag integer,
    uniqueid UUID default uuid_generate_v4() primary key,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);

drop table if exists promotion_av;
CREATE TABLE public.Stores (
    ownerid UUID references promotion(uniqueID),
    type integer,
    name character varying(128),
    intvalue integer,
    stringvalue character varying(128),
    datevalue character varying(128),
    lastmodified timestamp default current_timestamp
);


drop table if exists PromotionStoreAssignment;
CREATE TABLE public.Stores (
    PromotionUUID UUID references promotion(uniqueID),
    StoreUUID UUID references Stores(uniqueID)
    );


drop table if exists PromotionPoolAssignment;
CREATE TABLE public.Stores (
    PromotionUUID UUID references promotion(uniqueID),
    PoolUUID UUID references Pool(uniqueID)
    );

drop table if exists PromotionDSAssignment;
CREATE TABLE public.Stores (
    PromotionUUID UUID references promotion(uniqueID),
    dsuuid UUID references deliveryslip(uniqueID)
    );


drop table if exists PoolConditionRules;
CREATE TABLE public.PoolConditionRules (
    ruleID character varying(28),
    columnName character varying(28),
    operator character varying(28) ,
    values character varying(28) ,
    uniqueid UUID default uuid_generate_v4() primary key,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);


drop table if exists PromoCondtion_Pool;
CREATE TABLE public.promotion (
    poolName character varying(28),
    poolType timestamp default current_timestamp,
    ruleUUID UUID references PoolConditionRules(uniqueID), ,
    enabledflag integer,
    uniqueid UUID default uuid_generate_v4() primary key,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);


drop table if exists giftVoucher;
CREATE TABLE public.giftVoucher (
    GiftVoucherID serial NOT NULL,,
    GiftVoucherNumber integer,
    Description character varying(28),
    ExpiryDate timestamp default current_timestamp,,
    TotalGVAmount decimal(12,2),,
    UsedAmount decimal(12,2),,
    uniqueid UUID default uuid_generate_v4() primary key,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);


/*
itemdivisions
(id serial,
Name character varying(28),
Description character varying(28),
parentID UUID references itemdivisions(UUID),
uniqueid UUID default uuid_generate_v4() primary key,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
 )


1,'Ladies','ladies main division',NULL,u0001201,sysdate,sysdate
2, 'Pattu','ladies subsection costly',u0001201,u0001202,sysdate,sysdate


drop table if exists ProductItem;

CREATE TABLE public.ProductItem (
    id serial NOT NULL,
    barcode varchar(255) NOT NULL,
    categoryid ,



    uniqueid UUID default uuid_generate_v4() primary key,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
    )

product_av
categoryassignment
productlistprice
productimage


CREATE TABLE public.productInventory
(
    productuuid   references ProductItem(uniqueid),
    stock number,
    uniqueid UUID default uuid_generate_v4() primary key,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);

CREATE TABLE public.productImage
(
    productuuid   references ProductItem(uniqueid),
    image character,
    uniqueid UUID default uuid_generate_v4() primary key,
    creationdate timestamp default current_timestamp,
    lastmodified timestamp default current_timestamp
);




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
    attr_25 varchar(255) NULL,
    CONSTRAINT barcode_itemsku UNIQUE (barcode, item_sku),
    CONSTRAINT barcode_unique UNIQUE (barcode),
    CONSTRAINT pos_inventories_pkey PRIMARY KEY (id),
    CONSTRAINT pos_inventories_uom_check CHECK (((uom)::text = ANY (ARRAY[('units'::character varying)::text, ('meters'::character varying)::text])))
);




attr_1  Y   DIVISION
attr_2  Y   SECTION
attr_3  Y   SUBSECTION
attr_4  Y   SUBSECTION_ID

attr_10 Y   INVOICE_LINENO
attr_11 Y   BatchNo
attr_12 Y   Category 2
attr_13 Y   Size
attr_14 Y   Color
attr_15 N   attr_15
attr_16 N   PURCHASE TAX % - PKM
attr_17 N   PURCHASE INV ID - PKM
attr_18 N   V-COLOR CODE
attr_19 N   SHORT CODE

attr_20 N   attr_20
attr_21 Y   SECOND COLOR
attr_22 N   NOT IN USE
attr_23 N   NOT IN USE
attr_24 N   NOT IN USE
attr_25 N   NOT IN USE

attr_5  Y   STYLE CODE
attr_6  N   DCODE
attr_7  N   SID
attr_8  N   CNSNO
attr_9  N   INVOICENO

1. Product table will not have attr columns, instead it will have the actual names defaultcategoryid
1a. product_av
2. Catalogcategory which is a master lookup for all categories
3. PCA (product category assignment) join table - record wil be inserted
4. PLP/PCP productlistprice/costprice 
5. Inventory /stock


Tasks.

1. Alter the SQL dump file. as per Ramesh suggestions
2. Vaguely creating the above 5 tables  
3. Gift Voucher functionality implementation at DB level

*/
