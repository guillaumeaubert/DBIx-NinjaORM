-- Accounts table for use in JOIN tests --
CREATE TABLE accounts
(
	account_id bigint(20) unsigned NOT NULL auto_increment,
	email varchar(128) NOT NULL,
	created bigint(20) NOT NULL default '0',
	modified bigint(20) NOT NULL default '0',
	UNIQUE KEY idx_unique_email (email)
);

-- Standard table. --
CREATE TABLE tests
(
	test_id bigint(20) unsigned NOT NULL auto_increment,
	name varchar(32) NOT NULL,
	value varchar(128) DEFAULT NULL,
	account_id bigint(20) unsigned DEFAUL NULL REFERENCES accounts(account_id),
	created bigint(20) unsigned NOT NULL default '0',
	modified bigint(20) unsigned NOT NULL default '0',
	PRIMARY KEY (test_id),
	UNIQUE KEY idx_unique_name (name)
);

-- Table without a "created" field. --
CREATE TABLE tests
(
	test_id bigint(20) unsigned NOT NULL auto_increment,
	name varchar(32) NOT NULL,
	value varchar(128) DEFAULT NULL,
	modified bigint(20) unsigned NOT NULL default '0',
	PRIMARY KEY (test_id),
	UNIQUE KEY idx_unique_name (name)
);

-- Table without a "modified" field. --
CREATE TABLE tests
(
	test_id bigint(20) unsigned NOT NULL auto_increment,
	name varchar(32) NOT NULL,
	value varchar(128) DEFAULT NULL,
	created bigint(20) unsigned NOT NULL default '0',
	PRIMARY KEY (test_id),
	UNIQUE KEY idx_unique_name (name)
);