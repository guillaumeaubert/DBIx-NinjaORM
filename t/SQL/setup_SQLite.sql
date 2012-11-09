-- Standard table. --
CREATE TABLE tests
(
	test_id INTEGER PRIMARY KEY AUTOINCREMENT,
	name VARCHAR(32) NOT NULL,
	value VARCHAR(128) DEFAULT NULL,
	created BIGINT(20) NOT NULL DEFAULT '0',
	modified BIGINT(20) NOT NULL DEFAULT '0',
	UNIQUE (name)
);

-- Table without a "created" field. --
CREATE TABLE no_created_tests
(
	test_id INTEGER PRIMARY KEY AUTOINCREMENT,
	name VARCHAR(32) NOT NULL,
	value VARCHAR(128) DEFAULT NULL,
	modified BIGINT(20) NOT NULL DEFAULT '0',
	UNIQUE (name)
);

-- Table without a "modified" field. --
CREATE TABLE no_modified_tests
(
	test_id INTEGER PRIMARY KEY AUTOINCREMENT,
	name VARCHAR(32) NOT NULL,
	value VARCHAR(128) DEFAULT NULL,
	created BIGINT(20) NOT NULL DEFAULT '0',
	modified BIGINT(20) NOT NULL DEFAULT '0',
	UNIQUE (name)
);
