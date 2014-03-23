/*
MySQL Data Transfer
Source Host: faintlink.com
Source Database: faintlink
Target Host: faintlink.com
Target Database: faintlink
Date: 23/03/2009 18:57:49
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for dogfight
-- ----------------------------
DROP TABLE IF EXISTS `dogfight`;
CREATE TABLE `dogfight` (
  `steamid` varchar(35) NOT NULL,
  `kills` int(10) NOT NULL DEFAULT '0',
  `deaths` int(10) NOT NULL DEFAULT '0',
  `money` int(10) NOT NULL,
  `unlocks` varchar(500) NOT NULL,
  `tc` int(10) NOT NULL DEFAULT '0',
  `ttd` int(100) NOT NULL DEFAULT '0',
  PRIMARY KEY (`steamid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;