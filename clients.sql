/*
MySQL Data Transfer
Source Host: faintlink.com
Source Database: faintlink
Target Host: faintlink.com
Target Database: faintlink
Date: 23/03/2009 18:57:34
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for clients
-- ----------------------------
DROP TABLE IF EXISTS `clients`;
CREATE TABLE `clients` (
  `name` varchar(50) NOT NULL,
  `steamid` varchar(25) NOT NULL,
  `server` varchar(5) NOT NULL DEFAULT '0',
  `groups` varchar(6) NOT NULL DEFAULT 'U',
  `timeplayed` int(100) NOT NULL DEFAULT '0',
  PRIMARY KEY (`steamid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;