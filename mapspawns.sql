CREATE TABLE IF NOT EXISTS `mapspawns` (
  `server_id` int(11) NOT NULL AUTO_INCREMENT,
  `map` varchar(50) NOT NULL,
  `team_id` tinyint(4) NOT NULL DEFAULT '0',
  `position` varchar(50) NOT NULL,
  `angle` varchar(50) NOT NULL,
  PRIMARY KEY (`server_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;