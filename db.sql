-- Table: public.t_invoice

-- DROP TABLE IF EXISTS public.t_invoice;

CREATE TABLE IF NOT EXISTS public.t_invoice
(
    line bigint NOT NULL DEFAULT 0,
    invoiceno character varying COLLATE pg_catalog."default" DEFAULT ''::character varying,
    customer character varying COLLATE pg_catalog."default" DEFAULT ''::character varying,
    invoicedate character varying COLLATE pg_catalog."default" DEFAULT ''::character varying,
    payamount character varying COLLATE pg_catalog."default" DEFAULT ''::character varying,
    invoiceamout character varying COLLATE pg_catalog."default",
    detailline bigint,
    description character varying COLLATE pg_catalog."default",
    currency character varying COLLATE pg_catalog."default",
    usd character varying COLLATE pg_catalog."default",
    charge real DEFAULT 0.0,
    hst character varying COLLATE pg_catalog."default",
    total real DEFAULT 0.0,
    note character varying COLLATE pg_catalog."default" DEFAULT ''::character varying,
    date character varying COLLATE pg_catalog."default",
    noall character varying COLLATE pg_catalog."default",
    exchange real DEFAULT 1.0,
    CONSTRAINT pk_t_invoice PRIMARY KEY (line)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.t_invoice
    OWNER to root;

-- View: public.v_invoice

-- DROP VIEW public.v_invoice;

CREATE OR REPLACE VIEW public.v_invoice
 AS
 SELECT
        CASE
            WHEN t1.description::text = ANY (ARRAY['Gst'::character varying::text, 'Gst And Duty'::character varying::text, 'Gst Deburstment'::character varying::text, 'Gst Disburment'::character varying::text, 'Gst Disbursement'::character varying::text, 'Gst Disbursemetn'::character varying::text, 'Gst Disbursment'::character varying::text, 'Gst Disburstment'::character varying::text, 'Gst Discursement.'::character varying::text, 'Import Gst'::character varying::text]) THEN 'Gst Disburstment'::text
            WHEN t1.description::text = ANY (ARRAY['Brokerage Charge'::character varying::text, 'Custom Clearance'::character varying::text, 'Customs Clearance'::character varying::text, 'Customs Clearance Fee'::character varying::text, 'Customs Clearance.'::character varying::text]) THEN 'Customs Clearance'::text
            WHEN t1.description::text = ANY (ARRAY['Wire Fee'::character varying::text, 'Bnak Fee'::character varying::text, 'Bank Charge'::character varying::text, 'Bank Charge 3%'::character varying::text, 'Bank Charges'::character varying::text, 'Bank Fee'::character varying::text, 'Banking Charge'::character varying::text, 'Credit'::character varying::text, 'Credit Card 3%'::character varying::text, 'Credit Card Charge'::character varying::text, 'Credit Card Service Charge'::character varying::text]) THEN 'Bank Charge'::text
            WHEN t1.description::text = ANY (ARRAY['Duties'::character varying::text, 'Duties Dibsursement'::character varying::text, 'Duties Disbrusement'::character varying::text, 'Duties Disbursement'::character varying::text, 'Duties Disbursment'::character varying::text, 'Duty'::character varying::text, 'Duty And Tax'::character varying::text, 'Duty Deburstment'::character varying::text, 'Duty Disbursement'::character varying::text, 'Gst(Disbursement)'::character varying::text]) THEN 'Duties Disbursement'::text
            WHEN t1.description::text = ANY (ARRAY['Gst For Custom Clerance'::character varying::text, 'Gst For Customs Clearance'::character varying::text, 'Gst For Customs Clearance Fee'::character varying::text, 'Gst Of Customs Clearance'::character varying::text, 'Gst Of Storage'::character varying::text, 'Gst On Customs Clearance'::character varying::text, 'Tax'::character varying::text]) THEN 'GST on Customer Clearance'::text
            WHEN t1.description::text = 'Hst'::text THEN 'Hst'::text
            WHEN t1.description::text = ANY (ARRAY['Rent - Jul 2024'::character varying::text, 'Rent - Jun 2024'::character varying::text, 'Rent - Sep 2024'::character varying::text, 'Rent- Aug 2024'::character varying::text, 'Rent-Half Month In Apr.'::character varying::text, 'Rental - Aug 2024'::character varying::text, 'Rental - Jul 2024'::character varying::text]) THEN 'Rental'::text
            WHEN t1.description::text = ANY (ARRAY['Deposit'::character varying::text, 'Deposit Deduction'::character varying::text, 'Rent- May 2024 （Deducted From The Deposit）'::character varying::text, 'Empty Return Deposit'::text, 'Refundable Deposit'::text, 'Soc Deposit Fee'::text, 'Trucking Deposit'::text]) THEN 'Deposit'::text
            ELSE 'Sales'::text
        END AS category,
    t1.line,
    t1.invoiceno,
    t1.customer,
    t1.invoicedate,
    t1.payamount,
    t1.invoiceamout,
    t1.detailline,
    t1.description,
    t1.currency,
    t1.charge,
    t1.hst,
    t1.total,
    t1.note,
    t1.date,
    t1.noall,
    t1.exchange
   FROM t_invoice t1
  WHERE t1.description::text <> 'Gst'::text;

ALTER TABLE public.v_invoice
    OWNER TO root;

-- select count(1) as c, t1000."InvoiceNo" from
create view v_output as 
select * from 
( select 
	t1.line as Line,
	t1.invoicedate as "InvoiceDate",
	t1.invoiceno as "InvoiceNo",
	c100.total as "Custom Clearance",
	c101.total as "GST on Customer Clearance",
	c200.total as "Duties Disbursement",
	c300.total as "Gst Disburstment",
	c400.total as "Rent",
	c401.total as "Hst",
	c500.total as "Sales",
	c600.total as "Bank Charge",
	c700.total as "Deposit",
	c800.total as "GST",
	t1.payamount as "Paid",
	t1.invoiceamout as "Total Amt.",
	t1.note as Note
from t_invoice t1
inner join 
(select distinct c1.noall from t_temp c1) t2 on 
t1.invoiceno=t2.noall and t1.detailline=1
Left Join
(select v1.noall, v1.category, sum(total) as total
from v_invoice v1
where v1.category='Customs Clearance'
group by v1.noall, v1.category
) c100 on t1.invoiceno = c100.noall and t2.noall=c100.noall 
Left Join
(select v1.noall, v1.category, sum(total) as total
from v_invoice v1
where v1.category='GST on Customer Clearance'
group by v1.noall, v1.category
) c101 on t1.invoiceno = c101.noall and t2.noall=c101.noall
Left Join
(select v1.noall, v1.category, sum(total) as total
from v_invoice v1
where v1.category='Duties Disbursement'
group by v1.noall, v1.category
) c200 on t1.invoiceno = c200.noall and t2.noall=c200.noall 
Left Join
(select v1.noall, v1.category, sum(total) as total
from v_invoice v1
where v1.category='Gst Disburstment'
group by v1.noall, v1.category
) c300 on t1.invoiceno = c300.noall and t2.noall=c300.noall

Left Join
(select v1.noall, v1.category, sum(total) as total
from v_invoice v1
where v1.category='Rental'
group by v1.noall, v1.category
) c400 on t1.invoiceno = c400.noall and t2.noall=c400.noall
Left Join
(select v1.noall, v1.category, sum(total) as total
from v_invoice v1
where v1.category='Hst'
group by v1.noall, v1.category
) c401 on t1.invoiceno = c401.noall and t2.noall=c401.noall 
Left Join
(select v1.noall, v1.category, sum(total) as total
from v_invoice v1
where v1.category='Sales'
group by v1.noall, v1.category
) c500 on t1.invoiceno = c500.noall and t2.noall=c500.noall

Left Join
(select v1.noall, v1.category, sum(total) as total
from v_invoice v1
where v1.category='Bank Charge'
group by v1.noall, v1.category
) c600 on t1.invoiceno = c600.noall and t2.noall=c600.noall

Left Join
(select v1.noall, v1.category, sum(total) as total
from v_invoice v1
where v1.category='Deposit'
group by v1.noall, v1.category
) c700 on t1.invoiceno = c700.noall and t2.noall=c700.noall

Left Join
(select v1.noall, sum(cast(total as real)) as total
from t_invoice v1
where description='Gst' and cast(total as real) > 0
group by v1.noall
) c800 on t1.invoiceno = c800.noall and t2.noall=c800.noall 
) t1000
-- group by t1000."InvoiceNo"
--Where t1000."InvoiceNo"='VAN33346'
order by t1000."line"



