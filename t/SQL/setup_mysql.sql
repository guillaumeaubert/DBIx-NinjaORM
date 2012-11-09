-- Standard table. --
CREATE TABLE tests
(
	test_id bigint(20) unsigned NOT NULL auto_increment,
	name varchar(32) NOT NULL,
	value varchar(128) DEFAULT NULL,
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
