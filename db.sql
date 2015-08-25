-- phpMyAdmin SQL Dump
-- version 4.2.7.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Nov 01, 2014 at 06:31 PM
-- Server version: 5.6.20
-- PHP Version: 5.5.15

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `azerron_database`
--

-- --------------------------------------------------------

--
-- Table structure for table `abilities`
--

CREATE TABLE IF NOT EXISTS `abilities` (
`id` int(11) NOT NULL,
  `name` varchar(80) CHARACTER SET latin1 NOT NULL,
  `desc` varchar(400) CHARACTER SET latin1 NOT NULL,
  `anim` int(80) NOT NULL,
  `icon` varchar(80) CHARACTER SET latin1 NOT NULL,
  `fx` varchar(255) CHARACTER SET latin1 NOT NULL,
  `isAuto` tinyint(1) NOT NULL DEFAULT '0',
  `isHeal` int(1) NOT NULL DEFAULT '0',
  `isFriendly` tinyint(4) NOT NULL DEFAULT '0',
  `rpType` int(11) NOT NULL DEFAULT '1',
  `rpCost` int(11) NOT NULL,
  `critChance` float NOT NULL DEFAULT '-1',
  `subType` int(11) NOT NULL DEFAULT '1',
  `amount` float NOT NULL DEFAULT '1',
  `cd` float NOT NULL DEFAULT '-1',
  `range` float NOT NULL DEFAULT '-1',
  `auras` varchar(255) CHARACTER SET latin1 NOT NULL,
  `maxTgt` int(11) NOT NULL DEFAULT '1',
  `minTgt` int(11) NOT NULL DEFAULT '1',
  `lvlReq` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci AUTO_INCREMENT=7 ;

--
-- Dumping data for table `abilities`
--

INSERT INTO `abilities` (`id`, `name`, `desc`, `anim`, `icon`, `fx`, `isAuto`, `isHeal`, `isFriendly`, `rpType`, `rpCost`, `critChance`, `subType`, `amount`, `cd`, `range`, `auras`, `maxTgt`, `minTgt`, `lvlReq`) VALUES
(1, 'Auto Attack', 'A basic attack.', 1, 'sw1', '', 1, 0, 0, 1, 0, -1, 1, 1, -1, -1, '', 1, 1, 0),
(2, 'Hold The Line', 'Reduce incoming melee damage by 30% for 10 seconds.', 2, 'sh1', 'c:1', 0, 0, 1, 1, 20, -1, 0, 0, 18, -1, 'c:1', 0, 0, 4),
(3, 'Ferocious Strike', 'Attack and deal 150% weapon damage,  plus 10% of damage dealt every 2 seconds for 10 seconds.', 1, 'sw3', 't:2', 0, 0, 0, 1, 25, -1, 1, 2, 5.5, -1, 't:2', 1, 1, 2),
(4, 'Heal', 'Heal a target with your faith in the light.', 2, 'hl1', 't:3', 0, 1, 1, 1, 35, 0.5, 1, 1, 6, 1000, '', 1, 0, 0),
(5, 'King''s Justice', 'Dispense the King''s justice, dealing 70% weapon damage to up to 3 targets.', 2, 'sw4', 'c:4,t:5', 0, 0, 0, 1, 30, -1, 1, 0.7, 3.5, 1000, '', 3, 1, 5),
(6, 'Firebolt', 'Shoot a fireball at your target. ', 1, 'fb1', 't:6', 1, 0, 0, 1, 15, -1, 1, 1, -1, 1000, '', 1, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `auras`
--

CREATE TABLE IF NOT EXISTS `auras` (
`id` int(11) NOT NULL,
  `name` varchar(225) NOT NULL,
  `type` int(11) NOT NULL,
  `seconds` int(11) NOT NULL,
  `ticks` int(11) NOT NULL DEFAULT '0',
  `subType` int(11) NOT NULL DEFAULT '1',
  `amount` float NOT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `auras`
--

INSERT INTO `auras` (`id`, `name`, `type`, `seconds`, `ticks`, `subType`, `amount`) VALUES
(1, 'Swordsman', 0, 10, 1, 1, 0.3),
(2, 'Internal Bleeding', 2, 10, 5, 1, 0.1),
(3, 'Holy Blessing', 1, 10, 5, 1, 0.3);

-- --------------------------------------------------------

--
-- Table structure for table `characters`
--

CREATE TABLE IF NOT EXISTS `characters` (
`id` int(11) NOT NULL,
  `username` varchar(500) NOT NULL,
  `password` varchar(500) NOT NULL,
  `email` varchar(255) NOT NULL,
  `access` int(5) NOT NULL DEFAULT '1',
  `gold` int(11) NOT NULL DEFAULT '0',
  `xp` int(11) NOT NULL DEFAULT '0',
  `level` int(11) NOT NULL DEFAULT '1',
  `classId` int(11) NOT NULL DEFAULT '0',
  `armorId` int(255) NOT NULL,
  `weaponId` int(150) NOT NULL DEFAULT '6',
  `gender` tinyint(1) NOT NULL DEFAULT '0',
  `inventorySlots` int(10) NOT NULL DEFAULT '24',
  `lastZone` varchar(255) NOT NULL DEFAULT 'forest',
  `lastRoom` varchar(255) NOT NULL DEFAULT 'Room1',
  `quests` text NOT NULL,
  `dateCreated` datetime NOT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Dumping data for table `characters`
--

INSERT INTO `characters` (`id`, `username`, `password`, `email`, `access`, `gold`, `xp`, `level`, `classId`, `armorId`, `weaponId`, `gender`, `inventorySlots`, `lastZone`, `lastRoom`, `quests`, `dateCreated`) VALUES
(1, 'admin', '6d6a1f2b4b4183a0327eeb61c4673672', '', 5, 6071, 150, 1, 1001, 2001, 6, 0, 24, 'forest', 'Left1', '', '0000-00-00 00:00:00'),
(2, 'kyverr', '6d6a1f2b4b4183a0327eeb61c4673672', 'john@ymail.com', 5, 1699700, 879611, 60, 1001, 2000, 15, 0, 24, 'forest', 'Left1', '0,1', '0000-00-00 00:00:00'),
(3, 'elitis', '4f027314fd9cd0183ea3a1f8234cd655', '', 4, 827, 1500, 3, 1001, 2000, 6, 0, 24, 'inn', 'Room1', ',1,2', '0000-00-00 00:00:00'),
(4, 'Divien', '4a122dc90d345521461bdf608e41575d', 'en3rgyx@gmail.com', 3, 74199, 2075, 8, 0, 2000, 13, 0, 24, 'forest', 'Room1', '0,1,3,2', '2014-11-01 05:18:18');

-- --------------------------------------------------------

--
-- Table structure for table `classes`
--

CREATE TABLE IF NOT EXISTS `classes` (
  `id` int(11) NOT NULL,
  `name` varchar(120) NOT NULL,
  `description` varchar(355) NOT NULL,
  `abilities` varchar(180) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `classes`
--

INSERT INTO `classes` (`id`, `name`, `description`, `abilities`) VALUES
(0, 'Humanoid', 'A simple peasant.', '1'),
(1, 'Warrior', 'The basic warrior.', '1,3,5,4,2'),
(2, 'Mage', 'A basic spell-slinger.', '6,6,6,6,6');

-- --------------------------------------------------------

--
-- Table structure for table `containers`
--

CREATE TABLE IF NOT EXISTS `containers` (
`id` int(11) NOT NULL,
  `items` varchar(450) NOT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `containers`
--

INSERT INTO `containers` (`id`, `items`) VALUES
(1, '8:2,9:98');

-- --------------------------------------------------------

--
-- Table structure for table `enemies`
--

CREATE TABLE IF NOT EXISTS `enemies` (
`id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `level` int(11) NOT NULL DEFAULT '1',
  `type` tinyint(1) NOT NULL DEFAULT '0',
  `hp` int(11) NOT NULL,
  `file` varchar(255) NOT NULL,
  `linkage` varchar(255) NOT NULL,
  `damage` varchar(255) NOT NULL DEFAULT '8-12',
  `itemDrops` varchar(255) NOT NULL,
  `questDrops` varchar(256) NOT NULL COMMENT 'id:percentage'
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `enemies`
--

INSERT INTO `enemies` (`id`, `name`, `level`, `type`, `hp`, `file`, `linkage`, `damage`, `itemDrops`, `questDrops`) VALUES
(1, 'Alpha Wolf', 1, 0, 100, 'Wolf1.swf', 'Wolf1', '3-6', '', '1:1,1001:0.75'),
(2, 'Alpha Pack-Leader', 2, 1, 195, 'Wolf1.swf', 'Wolf1', '5-8', '', '2:1'),
(3, 'Elder Dragon', 5, 3, 450, 'Dragons/Dragon1.swf', 'Dragon1', '8-13', '7:1.0,9:0.5,5:0.2', '3:1');

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE IF NOT EXISTS `inventory` (
`id` int(250) NOT NULL,
  `userId` int(11) NOT NULL,
  `itemId` int(11) NOT NULL,
  `stack` int(5) NOT NULL DEFAULT '1'
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

--
-- Dumping data for table `inventory`
--

INSERT INTO `inventory` (`id`, `userId`, `itemId`, `stack`) VALUES
(4, 3, 6, 1),
(5, 3, 2000, 1),
(7, 2, 9, 37),
(8, 2, 7, 3),
(9, 2, 5, 3);

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE IF NOT EXISTS `items` (
`id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `icon` varchar(25) NOT NULL,
  `desc` varchar(255) NOT NULL DEFAULT '',
  `damage` varchar(35) NOT NULL DEFAULT '0',
  `cost` int(11) NOT NULL DEFAULT '0',
  `sellPrice` int(10) NOT NULL DEFAULT '0',
  `access` tinyint(1) NOT NULL DEFAULT '0',
  `currency` int(45) NOT NULL DEFAULT '0',
  `rarity` tinyint(2) NOT NULL DEFAULT '0',
  `maxStack` int(11) NOT NULL DEFAULT '1',
  `type` varchar(20) NOT NULL DEFAULT '0',
  `itemData` varchar(400) NOT NULL,
  `linkage` varchar(150) NOT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=9005 ;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`id`, `name`, `icon`, `desc`, `damage`, `cost`, `sellPrice`, `access`, `currency`, `rarity`, `maxStack`, `type`, `itemData`, `linkage`) VALUES
(1, 'Hammer Of Judgement', 'hammer', '', '15-17', 10450, 9000, 0, 0, 2, 1, '1,0', 'mace/kyverr_custom/hammer1.swf', 'Kyverr_Hammer1'),
(2, 'Spear Of Elitis', 'spear', '', '13-16', 3450, 2000, 2, 0, 3, 1, '1,0', 'polearm/belozw/spear1.swf', 'Belozw_Spear1'),
(3, 'Glowing Matrix Cube', 'matrix_cube', 'No one knows what this item is or where it came from.', '0', 5500, 4500, 0, 0, 2, 1, '2,2,1', 'the_matrix', ''),
(5, 'Large Pile Of Coins', 'gold_coins', 'This doesn''t seem fair...', '0', 1, 500, 0, 0, 0, 25, '0', '', ''),
(6, 'Sturdy Claymore', 'sword', '', '8-11', 0, 0, 0, 0, 0, 1, '1,0', 'sword/default_sword.swf', 'DefaultSword'),
(7, 'Lockbox', 'chest', '', '0', 0, 0, 0, 0, 1, 25, '2,3,1', '1', ''),
(8, 'Malethor''s Severed Hand', 'demon_orb', 'The demon''s severed claw is still clutching something...', '0', 0, -1, 0, 0, 5, 1, '0', '', ''),
(9, 'Junk', 'junk', 'It smells... Eww.', '0', 0, 50, 0, 0, 0, 100, '0', '', ''),
(10, 'Battle Master''s Skull Crusher', 'hammer', '', '19-35', 5, 0, 0, 9003, 3, 1, '1,0', 'mace/kyverr_custom/hammer1.swf', 'Kyverr_Hammer1'),
(11, 'Pumpkin Heart Sword', 'sword', '', '13-16', 9001, 1545, 0, 0, 2, 1, '1,0', 'sword/belozw/pumpkinheart1.swf', 'PumpkinHeart1'),
(12, 'Dragon Orb Blade', 'sword', '', '2-20', 5500, 3000, 0, 0, 1, 1, '1,0', 'sword/belozw/orb_sword.swf', 'OrbSword1'),
(13, 'Delucidator', 'sword', 'Some say this sword came from the Void plane.', '19-25', 16000, 1545, 0, 0, 2, 1, '1,0', 'sword/belozw/voidsword1.swf', 'VoidSword1'),
(14, 'Rusty Blade', 'sword', 'This weapon is very old. And it appears to be unstable.', '1-25', 2500, 1545, 0, 0, 2, 1, '1,0', 'sword/belozw/rusty_sword1.swf', 'RustySword1'),
(15, 'Malethor''s Fury', 'sword', 'As you look at this blade, your heart fills with cold dread.', '50-105', 1450000, 1545, 0, 0, 5, 1, '1,0', 'sword/belozw/voidsword2.swf', 'VoidSword2'),
(16, 'Kyverr''s Armor', 'armor1', 'Admin only!', '0', 1, 0, 3, 0, 5, 1, '1,1', 'admin/admin1.swf', 'Admin1'),
(1001, 'Warrior', 'armor1', 'A powerful warrior!', '0', 100, 0, 0, 0, 2, 1, '1,2', '1', ''),
(1002, 'Mage', 'armor1', 'A powerful spellslinger!', '0', 100, 0, 0, 0, 2, 1, '1,2', '2', ''),
(2000, 'Spooky Costume', 'armor1', 'BoooOoooooOoooOOOoo!', '0', 7000, 0, 0, 0, 1, 1, '1,1', 'costume1/Costume1.swf', 'Costume1'),
(2001, 'Azerron Knight', 'armor1', 'The traditional armor of a Valthron Knight.', '0', 1, 0, 0, 0, 1, 1, '1,1', 'knight1/knight1.swf', 'Knight1'),
(9001, 'Fragment of Vael''Thar', 'shard_yellow', 'A broken shard of Vael''Thar, Blade Of Justice, used by the Archangel of Judgement Kyverr.', '0', 1, 45, 0, 0, 3, 25, '0', '', ''),
(9002, 'Blood Shard', 'shard_red', 'These mysterious shards radiate an unholy aura. They feel hot to the touch, like fresh blood.', '0', 3500, 2850, 0, 0, 4, 20, '0', '', ''),
(9003, 'Badge Of Victory', 'badge_blue', 'Received from defeating an enemy in combat.', '0', 0, -1, 0, 0, 3, 1000, '0', '', ''),
(9004, 'Pumpkin Heart Sword', 'sword', '', '13-16', 8000, 1545, 0, 0, 2, 1, '1,0', 'sword/belozw/pumpkinheart1.swf', 'PumpkinHeart1');

-- --------------------------------------------------------

--
-- Table structure for table `log_admin_inform`
--

CREATE TABLE IF NOT EXISTS `log_admin_inform` (
`id` int(11) NOT NULL,
  `content` varchar(400) NOT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `log_admin_inform`
--

INSERT INTO `log_admin_inform` (`id`, `content`) VALUES
(1, 'Kicked user with id 2 from server with reason: Illegal Quest Data Request');

-- --------------------------------------------------------

--
-- Table structure for table `log_chat`
--

CREATE TABLE IF NOT EXISTS `log_chat` (
`id` int(11) NOT NULL,
  `uId` varchar(255) NOT NULL,
  `content` varchar(355) NOT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=155 ;

--
-- Dumping data for table `log_chat`
--

INSERT INTO `log_chat` (`id`, `uId`, `content`) VALUES
(1, '2', 'hi fgt'),
(2, '2', 'hi'),
(3, '3', 'hi'),
(4, '2', 'your a fgt'),
(5, '3', 'f u'),
(6, '2', 'lolk'),
(7, '3', 'xp work?'),
(8, '2', 'yup'),
(9, '2', 'try /xp'),
(10, '3', 'wheres the xp bar?'),
(11, '2', 'there is none'),
(12, '3', 'dont work'),
(13, '2', ' /givexp'),
(14, '2', 'like /xp 100'),
(15, '2', 'or /gold 1000'),
(16, '3', 'ah ok'),
(17, '3', 'so I can level up?'),
(18, '2', 'yup'),
(19, '2', 'target me and look at my level'),
(20, '3', '8'),
(21, '2', 'yup'),
(22, '3', 'and you look like w olf'),
(23, '3', 'GG'),
(24, '2', 'players don''t have portrais yet loool'),
(25, '3', 'add a rest?'),
(26, '2', 'yeah'),
(27, '3', 'i think we should be able to check how much xp needed until we level up?'),
(28, '2', 'I''ll do that eventually'),
(29, '2', 'it''s not that big of a deal'),
(30, '3', 'how does the skills work tho'),
(31, '2', 'quests working?'),
(32, '3', 'ye'),
(33, '3', 'if you do it via level'),
(34, '3', 'doesnt it makde it difficult to chane class?'),
(35, '2', 'what'),
(36, '3', 'unless level becomes 1 when you select a new class'),
(37, '3', 'but we only have 5 skills'),
(38, '3', ':/'),
(39, '2', 'w/e'),
(40, '2', 'we''ll deal with that in beta'),
(41, '2', 'for now this is fine'),
(42, '3', 'ye makes sense'),
(43, '3', 'Just keep 1 class in alpha haha'),
(44, '3', 'so now to implement armours'),
(45, '3', 'add the Knight Armours in shop?'),
(46, '3', ':D'),
(47, '3', 'DO Wolfs drop gold?'),
(48, '2', 'yup'),
(49, '3', 'Kyverr'),
(50, '3', 'Kyverr '),
(51, '1', 'what'),
(52, '3', 'lets both attack al 3 wolfs'),
(53, '3', 'then run around'),
(54, '1', 'sec'),
(55, '3', 'see how it goes'),
(56, '3', 'kk'),
(57, '1', 'ok'),
(58, '1', 'ready'),
(59, '3', 'wtf'),
(60, '3', 'my health went full'),
(61, '3', 'loool it was on like 10'),
(62, '1', 'yeah I gotta track that down'),
(63, '1', 'you''re dying but the client isn''t reflecting it'),
(64, '3', 'theres some client side lag'),
(65, '3', 'screenshot what you see on client'),
(66, '3', 'and ill do same'),
(67, '3', 'add the caketown music to the map'),
(68, '3', '!mod hi'),
(69, '1', 'equip a different weapon'),
(70, '1', 'move to another room'),
(71, '1', 'and come back'),
(72, '1', 'gogogogog'),
(73, '3', 'done'),
(74, '3', 'HEY'),
(75, '3', 'the legs on female looks fucked'),
(76, '1', 'get off my fucking server'),
(77, '2', 'lol ur naked cus u suk'),
(78, '7', 'Trash gaem'),
(79, '2', 'wtf m9'),
(80, '7', 'wow this is am ario kart ripoff'),
(81, '7', 'gg'),
(82, '2', 'WTF M9'),
(83, '7', 'yiff time'),
(84, '7', 'NO'),
(85, '2', 'LOLNO'),
(86, '2', 'fuck urself m9'),
(87, '7', 'WTFFF'),
(88, '2', 'no yiff 4u'),
(89, '7', 'MY HOPES AND DREAMS'),
(90, '2', 'lol git rekt'),
(91, '7', 'how does one attack'),
(92, '2', 'target'),
(93, '2', 'the'),
(94, '2', 'wolf'),
(95, '2', 'there you go'),
(96, '7', 'no lightning spells'),
(97, '2', 'lol ye cus ur bad'),
(98, '7', 'this game is horrible'),
(99, '7', 'writing a review on metacritic'),
(100, '2', 'WTF'),
(101, '2', 'LOOOOOOL'),
(102, '7', 'horrible balance'),
(103, '2', 'you suck so hard m9'),
(104, '2', 'buy the class'),
(105, '2', 'warrior'),
(106, '2', 'Menu &#62; shop'),
(107, '7', 'how do'),
(108, '7', 'omg'),
(109, '7', 'doesi t cost kyverr coins'),
(110, '2', 'maybe'),
(111, '7', 'am i sexy yet'),
(112, '2', 'yis'),
(113, '2', '10/10 would rape violently'),
(114, '2', 'I mean'),
(115, '7', 'wow trash game developers are rapists'),
(116, '2', 'would request sexual relations from'),
(117, '2', 'click the green plus icon to heal up'),
(118, '2', 'it''s like eating in wow'),
(119, '2', 'it''s on your character portrait'),
(120, '7', 'i see it fajeh'),
(121, '7', 'wheres my exp'),
(122, '2', 'you don''t get to see it LOLOL'),
(123, '7', 'WTF'),
(124, '2', 'I just autoleveled'),
(125, '7', 'WAS IS THIS POKEMON RED AND BLUE'),
(126, '2', 'git gud'),
(127, '7', 'WHAT*'),
(128, '7', 'how level'),
(129, '2', 'LOOOOL ADMIN COMMANDS FTW'),
(130, '7', 'OMFG'),
(131, '2', 'u mad broseph'),
(132, '7', 'what are blood shards'),
(133, '2', 'legendary items'),
(134, '2', 'you''ll use them to buy quest items'),
(135, '2', 'or something'),
(136, '2', 'idk'),
(137, '2', 'I just wanted to test legendary items'),
(138, '7', 'where does the blood come from'),
(139, '7', 'children?'),
(140, '7', 'puppies?'),
(141, '2', 'your nans period'),
(142, '7', 'WTFFF'),
(143, '2', 'LOL BE BUTTHURT'),
(144, '7', 'YOU SICK FUK'),
(145, '2', 'i shag her erry nite'),
(146, '2', 'git over it'),
(147, '7', 'on her period?'),
(148, '7', 'thats disgusting'),
(149, '2', 'yes'),
(150, '7', '&#62; added pumpkins to game'),
(151, '7', '&#62;only one who plays it'),
(152, '2', 'q.q'),
(153, '7', 'Jesse pet'),
(154, '4', 'Halla');

-- --------------------------------------------------------

--
-- Table structure for table `questlists`
--

CREATE TABLE IF NOT EXISTS `questlists` (
`id` int(11) NOT NULL,
  `quests` varchar(255) NOT NULL,
  `access` int(11) NOT NULL DEFAULT '1',
  `active` tinyint(4) NOT NULL DEFAULT '1'
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Dumping data for table `questlists`
--

INSERT INTO `questlists` (`id`, `quests`, `access`, `active`) VALUES
(0, '0', 1, 1),
(1, '1,2,3', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `quests`
--

CREATE TABLE IF NOT EXISTS `quests` (
`id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `startText` varchar(550) NOT NULL,
  `endText` varchar(550) NOT NULL,
  `objectives` varchar(255) NOT NULL,
  `rewards` varchar(255) NOT NULL,
  `reqQuest` int(11) NOT NULL DEFAULT '-1',
  `oneTime` varchar(1) NOT NULL DEFAULT '0',
  `isDaily` tinyint(1) NOT NULL DEFAULT '0',
  `reqLevel` int(11) NOT NULL DEFAULT '1',
  `access` tinyint(2) NOT NULL DEFAULT '1'
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `quests`
--

INSERT INTO `quests` (`id`, `name`, `startText`, `endText`, `objectives`, `rewards`, `reqQuest`, `oneTime`, `isDaily`, `reqLevel`, `access`) VALUES
(0, 'Generic Quest', 'Generic Quest Text', 'Generic Quest End Text', '0:1:Generic Objective', 'g:1337,xp:46920', -1, '0', 0, 1, 1),
(1, 'Wolf Slayer', 'Hey go kill exactly 2 wolves.', 'Do you always just do what everyone tells you? Whatever. Anyways. Good job, have some gold.', '1:2:Wolves Slain', 'g:1000,xp:550', -1, '1', 0, 1, 1),
(2, 'The Leader Of The Pack', 'Their leader must be stopped before he can complete his dark, wolfish plans!', 'Good job, %p%! I''m glad you were able to stop him in time.', '2:1:Alpha Pack-Leader Slain', 'g:1200,xp:750,i:2', 1, '1', 0, 1, 1),
(3, 'Pelt Collector', 'Bring me 3 pristine wolf pelts!', 'Thanks.', '1001:3:Pristine Wolf Pelts', 'g:1000,xp:550', -1, '0', 0, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `servers`
--

CREATE TABLE IF NOT EXISTS `servers` (
`id` int(11) NOT NULL,
  `isOnline` tinyint(1) NOT NULL DEFAULT '1',
  `serverIP` varchar(255) NOT NULL,
  `serverPort` varchar(255) NOT NULL,
  `serverName` varchar(255) NOT NULL,
  `serverAccess` int(11) NOT NULL,
  `serverCount` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `servers`
--

INSERT INTO `servers` (`id`, `isOnline`, `serverIP`, `serverPort`, `serverName`, `serverAccess`, `serverCount`) VALUES
(1, 1, 'localhost', '9339', 'Localhost (Dev)', 3, 0),
(2, 1, 'azerron.zapto.org', '9339', 'Admin Server', 3, 0),
(3, 1, 'azerron.com', '9339', 'Alpha Server', 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `shops`
--

CREATE TABLE IF NOT EXISTS `shops` (
`id` int(11) NOT NULL,
  `shopName` varchar(100) NOT NULL,
  `shopContents` varchar(700) NOT NULL,
  `access` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;

--
-- Dumping data for table `shops`
--

INSERT INTO `shops` (`id`, `shopName`, `shopContents`, `access`) VALUES
(1, 'Alpha Shop', '6,1,3,9002,10,1001,2001,12,13,14,15', 1),
(2, 'Staff Shop', '1,1002,2001,2', 3),
(6, 'Hallow''s Eve', '11,2000', 1);

-- --------------------------------------------------------

--
-- Table structure for table `zones`
--

CREATE TABLE IF NOT EXISTS `zones` (
`id` int(11) NOT NULL,
  `zoneName` varchar(255) NOT NULL,
  `swfURL` varchar(255) NOT NULL,
  `maxUsers` int(11) NOT NULL DEFAULT '8',
  `isPvP` tinyint(1) NOT NULL DEFAULT '0',
  `access` tinyint(1) NOT NULL DEFAULT '1',
  `enemyArchitecture` text NOT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=9 ;

--
-- Dumping data for table `zones`
--

INSERT INTO `zones` (`id`, `zoneName`, `swfURL`, `maxUsers`, `isPvP`, `access`, `enemyArchitecture`) VALUES
(1, 'forest', 'Hometown/Forest/Map1.swf', 8, 0, 0, 'Right1:3:1,Left1:4:1,Left2:5:2'),
(2, 'swamp', 'Swamp1/Map2.swf', 8, 0, 0, ''),
(3, 'inn', 'Hometown/Inn/Inn.swf', 8, 0, 0, ''),
(4, 'castle', 'Castle1/Castle.swf', 12, 0, 0, ''),
(5, 'the_matrix', 'The_Matrix/The_Matrix.swf', 5, 0, 0, ''),
(6, 'duel', 'Duel/Duel.swf', 2, 0, 0, ''),
(8, 'portal', 'Portal1/Portal.swf', 8, 0, 0, 'Room1:1:3');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `abilities`
--
ALTER TABLE `abilities`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `auras`
--
ALTER TABLE `auras`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `characters`
--
ALTER TABLE `characters`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `classes`
--
ALTER TABLE `classes`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `containers`
--
ALTER TABLE `containers`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `enemies`
--
ALTER TABLE `enemies`
 ADD PRIMARY KEY (`id`), ADD KEY `id` (`id`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `log_admin_inform`
--
ALTER TABLE `log_admin_inform`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `log_chat`
--
ALTER TABLE `log_chat`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `questlists`
--
ALTER TABLE `questlists`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `quests`
--
ALTER TABLE `quests`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `servers`
--
ALTER TABLE `servers`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `shops`
--
ALTER TABLE `shops`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `zones`
--
ALTER TABLE `zones`
 ADD PRIMARY KEY (`id`), ADD UNIQUE KEY `zoneName` (`zoneName`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `abilities`
--
ALTER TABLE `abilities`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT for table `auras`
--
ALTER TABLE `auras`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `characters`
--
ALTER TABLE `characters`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `containers`
--
ALTER TABLE `containers`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `enemies`
--
ALTER TABLE `enemies`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
MODIFY `id` int(250) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT for table `items`
--
ALTER TABLE `items`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=9005;
--
-- AUTO_INCREMENT for table `log_admin_inform`
--
ALTER TABLE `log_admin_inform`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `log_chat`
--
ALTER TABLE `log_chat`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=155;
--
-- AUTO_INCREMENT for table `questlists`
--
ALTER TABLE `questlists`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `quests`
--
ALTER TABLE `quests`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `servers`
--
ALTER TABLE `servers`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `shops`
--
ALTER TABLE `shops`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT for table `zones`
--
ALTER TABLE `zones`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=9;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
