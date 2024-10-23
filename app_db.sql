-- MySQL dump 10.13  Distrib 8.0.38, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: app
-- ------------------------------------------------------
-- Server version	8.0.39

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `favorite_practice_sets`
--

DROP TABLE IF EXISTS `favorite_practice_sets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favorite_practice_sets` (
  `user_id` int NOT NULL,
  `practice_set_id` int NOT NULL,
  PRIMARY KEY (`user_id`,`practice_set_id`),
  KEY `practice_set_id` (`practice_set_id`),
  CONSTRAINT `favorite_practice_sets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `favorite_practice_sets_ibfk_2` FOREIGN KEY (`practice_set_id`) REFERENCES `practice_set` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorite_practice_sets`
--

LOCK TABLES `favorite_practice_sets` WRITE;
/*!40000 ALTER TABLE `favorite_practice_sets` DISABLE KEYS */;
INSERT INTO `favorite_practice_sets` VALUES (1,1),(1,21),(1,39),(1,40);
/*!40000 ALTER TABLE `favorite_practice_sets` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_favorite_sets_check_if_set_deleted` BEFORE INSERT ON `favorite_practice_sets` FOR EACH ROW BEGIN
    DECLARE set_deleted INT;

    SELECT is_deleted INTO set_deleted
    FROM practice_set
    WHERE id = NEW.practice_set_id;

    -- If the set is deleted (i.e., is_deleted = 1), prevent the insert
    IF set_deleted = 1 THEN
        SIGNAL SQLSTATE '45000'  -- Custom error state
        SET MESSAGE_TEXT = 'Cannot favorite a deleted practice set.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_favorite_sets_check_if_set_private` BEFORE INSERT ON `favorite_practice_sets` FOR EACH ROW BEGIN
    DECLARE set_private INT;
    DECLARE author_user_id INT;

    SELECT private, user_id INTO set_private, author_user_id
    FROM practice_set
    WHERE id = NEW.practice_set_id;


    -- If the set is deleted (i.e., is_deleted = 1), prevent the insert
    IF set_private = 1 AND NEW.user_id != author_user_id THEN
        SIGNAL SQLSTATE '45000'  -- Custom error state
        SET MESSAGE_TEXT = 'Cannot favorite a private practice set.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `practice_session`
--

DROP TABLE IF EXISTS `practice_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `practice_session` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `practice_set_id` int NOT NULL,
  `time_started` datetime(3) DEFAULT NULL,
  `time_ended` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_user_id_session_idx` (`user_id`),
  KEY `fk_practice_set_id_session_idx` (`practice_set_id`),
  CONSTRAINT `fk_practice_session_set_id` FOREIGN KEY (`practice_set_id`) REFERENCES `practice_set` (`id`),
  CONSTRAINT `fk_practice_session_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practice_session`
--

LOCK TABLES `practice_session` WRITE;
/*!40000 ALTER TABLE `practice_session` DISABLE KEYS */;
INSERT INTO `practice_session` VALUES (1,1,1,NULL,NULL),(2,1,2,'2024-10-22 15:10:10.000','2024-10-22 15:15:00.000'),(4,1,40,NULL,NULL),(5,1,40,NULL,NULL),(6,1,2,NULL,NULL),(8,1,2,NULL,NULL),(12,1,3,NULL,NULL),(13,1,2,NULL,NULL),(14,1,1,NULL,NULL),(17,1,1,NULL,NULL),(20,1,2,NULL,NULL),(21,1,2,NULL,NULL);
/*!40000 ALTER TABLE `practice_session` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_practice_session_check_if_set_deleted` BEFORE INSERT ON `practice_session` FOR EACH ROW BEGIN
    DECLARE set_deleted INT;

    SELECT is_deleted INTO set_deleted
    FROM practice_set
    WHERE id = NEW.practice_set_id;

    -- If the set is deleted (i.e., is_deleted = 1), prevent the insert
    IF set_deleted = 1 THEN
        SIGNAL SQLSTATE '45000'  -- Custom error state
        SET MESSAGE_TEXT = 'Cannot create a practice session for a deleted practice set.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `practice_session_item`
--

DROP TABLE IF EXISTS `practice_session_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `practice_session_item` (
  `id` int NOT NULL AUTO_INCREMENT,
  `practice_session_id` int NOT NULL,
  `item_id` int NOT NULL,
  `user_answer` tinyint DEFAULT NULL,
  `time_started` datetime(3) DEFAULT NULL,
  `time_ended` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_practice_session_id_item_idx` (`practice_session_id`),
  KEY `fk_practice_session_item_set_item_id` (`item_id`),
  CONSTRAINT `fk_practice_session_item_session_id` FOREIGN KEY (`practice_session_id`) REFERENCES `practice_session` (`id`),
  CONSTRAINT `fk_practice_session_item_set_item_id` FOREIGN KEY (`item_id`) REFERENCES `practice_set_item` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practice_session_item`
--

LOCK TABLES `practice_session_item` WRITE;
/*!40000 ALTER TABLE `practice_session_item` DISABLE KEYS */;
INSERT INTO `practice_session_item` VALUES (1,1,1,1,'2024-10-22 15:10:10.000','2024-10-22 15:11:00.000'),(2,1,2,1,'2024-10-22 15:11:00.000','2024-10-22 15:12:05.000'),(3,1,3,1,'2024-10-22 15:12:05.000','2024-10-22 15:13:00.000'),(4,1,4,0,'2024-10-22 15:13:00.000','2024-10-22 15:15:00.000'),(9,4,1,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(10,4,2,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(11,4,3,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(12,4,4,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(13,5,1,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(14,5,2,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(15,5,3,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(16,5,4,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(17,6,1,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(18,6,2,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(19,6,3,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(20,6,4,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(22,8,11,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(23,8,10,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(24,8,9,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(25,8,8,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(26,12,11,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(27,12,10,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(28,12,9,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(29,12,8,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(30,13,11,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(31,13,10,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(32,13,9,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(33,13,8,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(34,14,11,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(35,14,10,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(36,14,9,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(37,14,8,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(38,17,1,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(39,17,2,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(40,17,3,0,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(41,17,4,0,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(45,20,5,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(46,20,6,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(47,20,7,0,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(48,20,8,0,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(49,21,5,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(50,21,6,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(51,21,7,0,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(52,21,8,0,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000');
/*!40000 ALTER TABLE `practice_session_item` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_practice_session_item_check_if_item_id_is_valid` BEFORE INSERT ON `practice_session_item` FOR EACH ROW BEGIN
	DECLARE session_set_id INT;
    
    -- Get the practice_set_id from the corresponding practice_session
    SELECT practice_set_id INTO session_set_id
    FROM practice_session
    WHERE id = NEW.practice_session_id;
    
	IF NOT EXISTS (
        SELECT 1
        FROM practice_set_item
        WHERE id = NEW.item_id
          AND practice_set_id = session_set_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'item_id does not exist in the corresponding practice_session_item.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `practice_set`
--

DROP TABLE IF EXISTS `practice_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `practice_set` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `set_name` varchar(255) NOT NULL,
  `created_timestamp` datetime(3) DEFAULT CURRENT_TIMESTAMP(3),
  `last_edited_timestamp` datetime(3) DEFAULT CURRENT_TIMESTAMP(3),
  `private` tinyint(1) DEFAULT '1',
  `is_deleted` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_practice_set_user_id_idx` (`user_id`),
  CONSTRAINT `fk_practice_set_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practice_set`
--

LOCK TABLES `practice_set` WRITE;
/*!40000 ALTER TABLE `practice_set` DISABLE KEYS */;
INSERT INTO `practice_set` VALUES (1,1,'pandas questions',NULL,NULL,0,0),(2,1,'systemd',NULL,'2024-10-23 17:24:17.000',1,0),(3,1,'math','2024-10-20 18:53:10.659','2024-10-20 18:53:10.659',0,0),(13,1,'new name','2024-10-20 19:27:05.375','2024-10-20 19:27:05.375',1,0),(21,2,'geo','2024-10-20 23:14:38.677','2024-10-22 14:28:28.000',1,0),(35,3,'ab','2024-10-21 12:57:48.015','2024-10-22 14:40:05.000',1,0),(36,1,'coolest set eveeeeeer','2024-10-21 12:57:51.422','2024-10-22 13:15:05.000',1,1),(39,1,'pawel','2024-10-21 13:01:25.562','2024-10-22 13:15:43.000',0,1),(40,1,'coolest set eveeeeeer','2024-10-21 13:04:38.525','2024-10-22 12:26:53.000',1,0),(41,1,'maths','2024-10-21 13:07:14.103','2024-10-22 14:39:56.000',1,0),(42,1,'maths','2024-10-21 13:07:36.050','2024-10-21 13:07:36.050',0,0),(43,1,'maths','2024-10-21 13:09:39.143','2024-10-21 13:09:39.143',0,0),(44,1,'maths','2024-10-21 13:17:01.222','2024-10-21 13:17:01.222',0,0),(45,1,'maths','2024-10-21 13:18:08.410','2024-10-22 12:27:53.000',0,0),(46,1,'maths','2024-10-21 13:43:37.505','2024-10-21 13:43:37.505',0,0),(47,1,'maths','2024-10-21 13:59:34.888','2024-10-21 13:59:34.888',0,0),(48,1,'maths','2024-10-21 13:59:40.969','2024-10-21 13:59:40.969',0,0),(49,1,'maths','2024-10-21 13:59:48.008','2024-10-21 13:59:48.008',0,0),(50,1,'sobb','2024-10-21 13:59:55.479','2024-10-21 13:59:55.479',1,0),(51,1,'hello world','2024-10-21 14:55:26.097','2024-10-22 10:15:36.000',0,1);
/*!40000 ALTER TABLE `practice_set` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_practice_set_timestamp_update` BEFORE UPDATE ON `practice_set` FOR EACH ROW BEGIN
    SET NEW.last_edited_timestamp = NOW();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_favorite_sets_remove_if_set_to_private` BEFORE UPDATE ON `practice_set` FOR EACH ROW BEGIN
	IF NEW.private = 1 AND OLD.private = 0 THEN
    DELETE FROM favorite_practice_sets
    WHERE practice_set_id = NEW.id AND user_id != NEW.user_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `practice_set_item`
--

DROP TABLE IF EXISTS `practice_set_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `practice_set_item` (
  `id` int NOT NULL AUTO_INCREMENT,
  `practice_set_id` int NOT NULL,
  `question` varchar(1000) NOT NULL,
  `answer` varchar(1000) NOT NULL,
  `order` int DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_practice_set_item_set_id_idx` (`practice_set_id`),
  CONSTRAINT `fk_practice_set_item_set_id` FOREIGN KEY (`practice_set_id`) REFERENCES `practice_set` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practice_set_item`
--

LOCK TABLES `practice_set_item` WRITE;
/*!40000 ALTER TABLE `practice_set_item` DISABLE KEYS */;
INSERT INTO `practice_set_item` VALUES (1,1,'How do you display basic information about a dataframe?','df.info()',NULL,0),(2,1,'How do you display the mean average for column Sales?','df[\"Sales\"].mean()',NULL,0),(3,1,'Set max columns displayed to 10','pd.display.max.columns = 10',NULL,0),(4,1,'Set max rows displayed to 15','pd.display.max.rows = 15',NULL,0),(5,2,'Start nginx?','systemctl start nginx',NULL,0),(6,2,'List all units?','systemctl list-all-units',NULL,0),(7,2,'Display logs for nginx?','journalctl -xue nginx',NULL,0),(8,2,'Reload daemons?','systemctl reload-daemons',NULL,0),(9,3,'2+2?','4',NULL,0),(10,3,'10+2?','12',NULL,0),(11,40,'sobczyk tu byl221222?','nie bylo',NULL,0),(12,40,'sobczyk tu byl tez?','no a jak 22122',NULL,0),(13,40,'sobczyk tu byl221222?fff','nie byloaaaaa',NULL,0),(15,41,'2+2?','4',NULL,0),(16,41,'10/2?','5',NULL,0),(17,41,'15*3?','45',NULL,0),(18,41,'10+2?','12',NULL,0),(19,42,'2+2?','4',NULL,0),(20,42,'10/2?','5',NULL,0),(21,42,'15*3?','45',NULL,0),(22,42,'10+2?','12',NULL,0),(23,43,'2+2?','4',NULL,0),(24,43,'10/2?','5',NULL,0),(25,43,'15*3?','45',NULL,0),(26,43,'10+2?','12',NULL,0),(27,44,'2+2?','4',NULL,0),(28,44,'10/2?','5',NULL,0),(29,44,'15*3?','45',NULL,0),(30,44,'10+2?','12',NULL,0),(31,45,'2+2?','4',NULL,1),(32,45,'10/2?','5',NULL,1),(33,45,'15*3?','45',NULL,0),(34,45,'10+2?','12',NULL,0),(35,46,'2+2?','4',NULL,0),(36,46,'10/2?','5',NULL,0),(37,46,'15*3?','45',NULL,0),(38,46,'10+2?','12',NULL,0),(39,47,'2+2?','4',NULL,0),(40,47,'10/2?','5',NULL,0),(41,47,'15*3?','45',NULL,0),(42,47,'10+2?','12',NULL,0),(43,48,'2+2?','4',NULL,0),(44,48,'10/2?','5',NULL,0),(45,48,'15*3?','45',NULL,0),(46,48,'10+2?','12',NULL,0),(47,49,'2+2?','4',NULL,0),(48,49,'10/2?','5',NULL,0),(49,49,'15*3?','45',NULL,0),(50,49,'10+2?','12',NULL,0),(51,50,'2+2?','4',NULL,0),(52,50,'10/2?','5',NULL,0),(53,50,'15*3?','45',NULL,0),(54,50,'10+2?','12',NULL,0),(55,51,'2+2?','4',NULL,0),(56,51,'10/2?','5',NULL,0),(57,51,'15*3?','45',NULL,0),(58,51,'10+2?','12',NULL,0),(59,40,'byl tu','no jak nie jak tak',NULL,0),(60,40,'have you ever?','nope',NULL,0),(61,40,'have you ever eaten?','yes',NULL,0),(68,40,'have you ever had a dog?','nope',NULL,0),(69,40,'have you ever eaten a sanwich?','yes',NULL,0),(72,40,'have you ever had a dog?','nope',NULL,0),(73,40,'have you ever eaten a sanwich?','yes',NULL,0),(74,40,'have you ever had a dog?','nope',NULL,0),(75,40,'have you ever eaten a sanwich?','yes',NULL,0),(76,40,'have you ever had a dog?','nope',NULL,0),(77,40,'have you ever eaten a sanwich?','yes',NULL,0),(78,40,'have you ever had a dog?','nope',NULL,0),(79,40,'have you ever eaten a sanwich?','yes',NULL,0),(80,40,'have you ever had a dog?','nope',NULL,0),(81,40,'have you ever eaten a sanwich?','yes',NULL,0),(82,40,'have you ever had a dog?','nope',NULL,0),(83,40,'have you ever eaten a sanwich?','yes',NULL,0),(84,40,'have you ever had a dog?','nope',NULL,0),(85,40,'have you ever eaten a sanwich?','yes',NULL,0),(86,40,'have you ever had a dog?','nope',NULL,0),(87,40,'have you ever eaten a sanwich?','yes',NULL,0),(88,36,'have you ever had a dog?','nope',NULL,0),(89,36,'have you ever eaten a sanwich?','yes',NULL,0),(90,2,'bla bla','ble ble',NULL,0);
/*!40000 ALTER TABLE `practice_set_item` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_practice_set_timestamp_after_item_insert` AFTER INSERT ON `practice_set_item` FOR EACH ROW BEGIN
    UPDATE practice_set
    SET last_edited_timestamp = NOW()
    WHERE id = NEW.practice_set_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_practice_set_timestamp_after_item_update` AFTER UPDATE ON `practice_set_item` FOR EACH ROW BEGIN
    UPDATE practice_set
    SET last_edited_timestamp = NOW()
    WHERE id = OLD.practice_set_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_practice_set_timestamp_after_item_delete` AFTER DELETE ON `practice_set_item` FOR EACH ROW BEGIN
    UPDATE practice_set
    SET last_edited_timestamp = NOW()
    WHERE id = OLD.practice_set_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `practice_set_tags`
--

DROP TABLE IF EXISTS `practice_set_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `practice_set_tags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `practice_set_id` int NOT NULL,
  `tag` varchar(255) NOT NULL,
  PRIMARY KEY (`id`,`practice_set_id`),
  KEY `fk_practice_set_tags_set_id_idx` (`practice_set_id`),
  CONSTRAINT `fk_practice_set_tags_set_id` FOREIGN KEY (`practice_set_id`) REFERENCES `practice_set` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practice_set_tags`
--

LOCK TABLES `practice_set_tags` WRITE;
/*!40000 ALTER TABLE `practice_set_tags` DISABLE KEYS */;
INSERT INTO `practice_set_tags` VALUES (1,1,'python'),(2,1,'pandas'),(3,1,'data analysis'),(4,1,'algebra'),(5,46,'algebra'),(6,46,'science'),(7,46,'data'),(8,46,'elo'),(9,47,'algebra'),(10,47,'science'),(11,47,'data'),(12,47,'elo'),(18,40,'lami'),(19,36,'lami');
/*!40000 ALTER TABLE `practice_set_tags` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_practice_set_timestamp_after_tag_insert` AFTER INSERT ON `practice_set_tags` FOR EACH ROW BEGIN
    UPDATE practice_set
    SET last_edited_timestamp = NOW()
    WHERE id = NEW.practice_set_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_practice_set_timestamp_after_tag_update` AFTER UPDATE ON `practice_set_tags` FOR EACH ROW BEGIN
    UPDATE practice_set
    SET last_edited_timestamp = NOW()
    WHERE id = OLD.practice_set_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_practice_set_timestamp_after_tag_delete` AFTER DELETE ON `practice_set_tags` FOR EACH ROW BEGIN
    UPDATE practice_set
    SET last_edited_timestamp = NOW()
    WHERE id = OLD.practice_set_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `e-mail` varchar(255) NOT NULL,
  `active` tinyint DEFAULT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `created_timestamp` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_UNIQUE` (`username`),
  UNIQUE KEY `e-mail_UNIQUE` (`e-mail`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'pudzian','$2b$12$Gnile6EWN2fAwBsFoSmwHue/K9ZStMWdsPMdlkiqeGN0WgHcUvW3u','pudzian@wp.pl',1,NULL,NULL,NULL),(2,'sobczyk','$2b$12$Gnile6EWN2fAwBsFoSmwHue/K9ZStMWdsPMdlkiqeGN0WgHcUvW3u','sobczyk@wp.pl',1,NULL,NULL,NULL),(3,'kuben','$2b$12$NgG6F0QGHiPmURI55Mo7oubp3YkAlnnpT1b.yExdfQrPE1uZPh9Le','kuben@lami.pl',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_prevent_user_delete` BEFORE DELETE ON `users` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deletion of users is not allowed. Set active to 0 instead.';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `v_practice_session_total_score`
--

DROP TABLE IF EXISTS `v_practice_session_total_score`;
/*!50001 DROP VIEW IF EXISTS `v_practice_session_total_score`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_practice_session_total_score` AS SELECT 
 1 AS `id`,
 1 AS `set_name`,
 1 AS `answers_correct`,
 1 AS `answers_total`,
 1 AS `answers_correct_percent`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_set_questions_all_info`
--

DROP TABLE IF EXISTS `v_set_questions_all_info`;
/*!50001 DROP VIEW IF EXISTS `v_set_questions_all_info`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_set_questions_all_info` AS SELECT 
 1 AS `id`,
 1 AS `question`,
 1 AS `answer`,
 1 AS `user_id`,
 1 AS `username`,
 1 AS `set_name`,
 1 AS `created_timestamp`,
 1 AS `last_edited_timestamp`,
 1 AS `private`,
 1 AS `is_deleted`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_sets_per_user`
--

DROP TABLE IF EXISTS `v_sets_per_user`;
/*!50001 DROP VIEW IF EXISTS `v_sets_per_user`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_sets_per_user` AS SELECT 
 1 AS `user_id`,
 1 AS `set_id`,
 1 AS `username`,
 1 AS `set_name`,
 1 AS `is_deleted`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'app'
--

--
-- Dumping routines for database 'app'
--

--
-- Final view structure for view `v_practice_session_total_score`
--

/*!50001 DROP VIEW IF EXISTS `v_practice_session_total_score`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_practice_session_total_score` AS select `ses`.`id` AS `id`,`pset`.`set_name` AS `set_name`,sum(`item`.`user_answer`) AS `answers_correct`,count(`item`.`id`) AS `answers_total`,round(((sum(`item`.`user_answer`) / count(`item`.`id`)) * 100),0) AS `answers_correct_percent` from ((`practice_session` `ses` join `practice_session_item` `item` on((`ses`.`id` = `item`.`practice_session_id`))) join `practice_set` `pset` on((`ses`.`practice_set_id` = `pset`.`id`))) group by `ses`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_set_questions_all_info`
--

/*!50001 DROP VIEW IF EXISTS `v_set_questions_all_info`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_set_questions_all_info` AS select `s`.`id` AS `id`,`i`.`question` AS `question`,`i`.`answer` AS `answer`,`s`.`user_id` AS `user_id`,`u`.`username` AS `username`,`s`.`set_name` AS `set_name`,`s`.`created_timestamp` AS `created_timestamp`,`s`.`last_edited_timestamp` AS `last_edited_timestamp`,`s`.`private` AS `private`,`i`.`is_deleted` AS `is_deleted` from ((`practice_set_item` `i` join `practice_set` `s` on((`s`.`id` = `i`.`practice_set_id`))) join `users` `u` on((`u`.`id` = `s`.`user_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_sets_per_user`
--

/*!50001 DROP VIEW IF EXISTS `v_sets_per_user`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_sets_per_user` AS select `users`.`id` AS `user_id`,`practice_set`.`id` AS `set_id`,`users`.`username` AS `username`,`practice_set`.`set_name` AS `set_name`,`practice_set`.`is_deleted` AS `is_deleted` from (`practice_set` join `users` on((`users`.`id` = `practice_set`.`user_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-10-23 17:30:17
