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
  STMT_CODE         VARCHAR(4),                     /* transaction type */
  STMT_REF          VARCHAR(16),                    /* reference for the account owner */
  STMT_BANKREF      VARCHAR(16),                    /* bank reference */
  STMT_GVC          INTEGER UNSIGNED,               /* business code (payment type) */
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
