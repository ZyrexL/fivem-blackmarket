USE `essentialmode`;

CREATE TABLE `blackmarket` (
	`id` int NOT NULL AUTO_INCREMENT,
	`store` varchar(100) NOT NULL,
	`item` varchar(100) NOT NULL,
	`price` int NOT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `blackmarket` (store, item, price) VALUES
	('blackmarket','water',30),
	('blackmarket','bread',30)
;