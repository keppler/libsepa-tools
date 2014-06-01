libsepa-tools
=============

*These tools require a valid [libsepa](https://libsepa.com) license!*

# parse_mt940

This tool uses [libsepa](https://libsepa.com) to parse account statements in MT940 format into a MySQL database.

Use the following database schema:

```SQL
CREATE TABLE STATEMENTS (
  STMT_ID           INTEGER UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
  STMT_VALUTA       DATE                NOT NULL,   /* value date */
  STMT_BOOKED       DATE,                           /* book date (entry date) */
  STMT_MYBANK       VARCHAR(11)         NOT NULL,   /* bank code or BIC of own account */
  STMT_MYACCOUNT    VARCHAR(34)         NOT NULL,   /* account number or IBAN of own account */
  STMT_AMOUNT       DECIMAL(12,2)       NOT NULL,   /* amount */
  STMT_CODE         VARCHAR(3),                     /* transaction type (see table below) */
  STMT_REF          VARCHAR(16),                    /* reference for the account owner */
  STMT_BANKREF      VARCHAR(16),                    /* bank reference */
  STMT_GVC          INTEGER UNSIGNED,               /* business code (payment type) */
  STMT_EXTCODE      INTEGER UNSIGNED,               /* extended code (for some SEPA transactions) */
  STMT_TXTEXT       VARCHAR(27),                    /* transaction text / description */
  STMT_PRIMANOTA    VARCHAR(10),                    /* primanota */
  STMT_BANK         VARCHAR(11),                    /* counterparty bank code or BIC */
  STMT_ACCOUNT      VARCHAR(34),                    /* counterparty account number or IBAN */
  STMT_NAME         VARCHAR(70),                    /* counterparty name */
  STMT_PURPOSE      VARCHAR(270),                   /* purpose */
  STMT_EREF         VARCHAR(35),                    /* SEPA end-to-end reference */
  STMT_KREF         VARCHAR(35),                    /* SEPA customer reference */
  STMT_MREF         VARCHAR(35),                    /* SEPA mandate reference (direct debit only) */
  STMT_CRED         VARCHAR(35),                    /* creditor ID (direct debit only) */
  STMT_DEBT         VARCHAR(35),                    /* originators identification code */
  STMT_COAM         DECIMAL(12,2),                  /* compensation amount (direct debit chargeback) */
  STMT_OAMT         DECIMAL(12,2),                  /* original amount (direct debit chargeback) */
  STMT_SVWZ         VARCHAR(140),                   /* SEPA purpose */
  STMT_ABWA         VARCHAR(70),                    /* differing debtor */
  STMT_ABWE         VARCHAR(70)                     /* differing creditor */
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
```

## Transaction Types - `STMT_CODE`

Usage of these codes strongly depends on your bank and sometime even on the account type. Most transaction are encoded just as `MSC` (miscellaneous).

Code | Text (according to SWIFT) | German translation
---- | ------------------------- | ------------------
BNK | Securities Related Item - Bank fees |
BOE | Bill of exchange | Sichttratte
BRF | Brokerage fee | Wertpapierprovision
CAR | Securities Related Item - Corporate Actions Related (Should only be used when no specific corporate action event code is available) |
CAS | Securities Related Item - Cash in Lieu |
CHG | Charges and other expenses | Gebühren und andere Auslagen
CHK | Cheques | Schecks
CLR | Cash letters/Cheques remittance | Geldbriefe/Scheckeinreichungen
CMI | Cash management item - No detail | Posten für Cash Management – Keine Einzelheiten
CMN | Cash management item - Notional pooling | Posten für Cash Management – Notional Pooling
CMP | Compensation claims |
CMS | Cash management item - Sweeping | Posten für Cash Management
CMT | Cash management item – Topping | Posten für Cash Management - Topping
CMZ | Cash management item - Zero balancing | Posten für Cash Management - Zero balancing
COL | Collections (used when entering a principal amount) | Inkassi (bei Angabe eines Hauptbetrages)
COM | Commission | Provision
CPN | Securities Related Item - Coupon payments |
DCR | Documentary credit (used when entering a principal amount) | Dokumentenakkreditiv (bei Angabe eines Hauptbetrages)
DDT | Direct Debit Item | Lastschriftposten
DIS | Securities Related Item - Gains disbursement |
DIV | Securities Related Item - Dividends | Dividenden
EQA | Equivalent amount | Equivalent amount (Gegenwertverrechnung)
EXT | Securities Related Item - External transfer for own account |
FEX | Foreign exchange | Foreign exchange (Devisenhandel)
INT | Interest | Interest (Zinsen)
LBX | Lock box | Schließfach
LDP | Loan deposit | Loan deposit (Darlehen)
MAR | Securities Related Item - Margin payments/Receipts |
MAT | Securities Related Item - Maturity |
MGT | Securities Related Item - Management fees |
MSC | Miscellaneous | Miscellaneous (Verschiedenes)
NWI | Securities Related Item - New issues distribution
ODC | Overdraft charge |
OPT | Securities Related Item - Options |
PCH | Securities Related Item - Purchase (including STIF and Time deposits) |
POP | Securities Related Item - Pair-off proceeds |
PRN | Securities Related Item - Principal paydown/pay-up |
REC | Securities Related Item - Tax reclaim |
RED | Securities Related Item - Redemption/Withdrawal |
RIG | Securities Related Item - Rights |
RTI | Returned item | Returned item (Rückbuchung)
SAL | Securities Related Item - Sale (including STIF and Time deposits)
SEC | Securities (used when entering a principal amount) | Wertpapiere (bei Angabe eines Hauptbetrages)
SLE | Securities Related Item - Securities lending related |
STO | Standing order | Standing order (Dauerauftrag)
STP | Securities Related Item - Stamp duty |
SUB | Securities Related Item - Subscription |
SWP | Securities Related Item - SWAP payment |
TAX | Securities Related Item - Withholding tax payment |
TCK | Travellers cheques | Reiseschecks
TCM | Securities Related Item - Tripartite collateral management |
TRA | Securities Related Item - Internal transfer for own account |
TRF | Transfer | Transfer (Übertrag)
TRN | Securities Related Item - Transaction fee |
UWC | Securities Related Item - Underwriting commission |
VDA | Value date adjustment | Berichtigung des Wertstellungsdatums (wenn eine Buchung unter einem falschen Datum ausgeführt wurde, wird dieser Code für die Korrektur verwendet - es folgt die korrekte Buchung mit dem entsprechenden Code)
WAR | Securities Related Item - Warranties

*Quelle: Die Deutsche Kreditwirtschaft, Anlage 3 des DFÜ-Abkommens (Spezifikation der Datenformate), Version 2.7, Kapitel 8.2.3 (PDF).*

## Business Code (GVC - Geschäftsvorfallcode) - `STMT_GVC`

(to be filled...)

## Extended SEPA Codes - `STMT_EXTCODE`

On transaction with GVC 104, 105, 108, 109, 159, 181 and 184, an additional SEPA code might be contained in the transaction details. This is useful eg. for automated processing of direct debit chargebacks.

`STMT_EXTCODE` | SEPA code | ISO name | Description (german)
-------------- | --------- | -------- | --------------------
901            | AC01      | IncorrectAccountNumber | Kontonummer fehlerhaft (ungültige IBAN)

(to be continued...)

## Examples

Example of a SEPA direct debit chargeback (VR-Bank / Fiducia):

Field | Value
----- | -----
STMT_ID | 27
STMT_VALUTA | 2014-05-09
STMT_BOOKED | NULL
STMT_MYBANK | 7*****33
STMT_MYACCOUNT | *****
STMT_AMOUNT | -74.97
STMT_CODE | MSC
STMT_REF |
STMT_BANKREF | NULL
STMT_GVC | 109
STMT_EXTCODE | 914
STMT_TXTEXT | RETOURE
STMT_PRIMANOTA | 5931
STMT_BANK | ****DE*****
STMT_ACCOUNT | DE53********000*******
STMT_NAME | ***** ************
STMT_PURPOSE | NULL
STMT_EREF | R123-45678-9
STMT_KREF | NULL
STMT_MREF | M12345-1
STMT_CRED | NULL
STMT_DEBT | NULL
STMT_COAM | 3.00
STMT_OAMT | 71.97
STMT_SVWZ | Retoure SEPA Lastschrift vom 09.05.2014, Rueckgabegrund: MS03 Rückgabegrund vom Kreditinstitut nicht spezifiziert SVWZ: Rechnung R123-45678
STMT_ABWA | NULL
STMT_ABWE | NULL
