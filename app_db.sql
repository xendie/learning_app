-- MySQL dump 10.13  Distrib 8.0.39, for Win64 (x86_64)
--
-- Host: localhost    Database: app
-- ------------------------------------------------------
-- Server version	8.0.39

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practice_session`
--

LOCK TABLES `practice_session` WRITE;
/*!40000 ALTER TABLE `practice_session` DISABLE KEYS */;
INSERT INTO `practice_session` VALUES (1,1,1,NULL,NULL),(2,1,2,'2024-10-22 15:10:10.000','2024-10-22 15:15:00.000'),(4,1,40,NULL,NULL),(5,1,40,NULL,NULL),(6,1,2,NULL,NULL),(8,1,2,NULL,NULL),(12,1,3,NULL,NULL),(13,1,2,NULL,NULL),(14,1,1,NULL,NULL),(17,1,1,NULL,NULL),(20,1,2,NULL,NULL),(21,1,2,NULL,NULL),(22,1,1,NULL,NULL),(23,1,1,NULL,NULL),(24,1,1,'2024-10-30 11:56:47.600','2024-10-30 11:56:51.084'),(25,1,1,'2024-10-30 12:33:08.044','2024-10-30 12:34:16.414'),(26,1,1,'2024-10-30 12:40:15.261','2024-10-30 12:40:18.626'),(27,1,1,'2024-10-30 12:44:20.378','2024-10-30 12:44:22.836'),(28,1,1,'2024-10-30 12:47:11.588','2024-10-30 12:47:13.554'),(29,1,1,'2024-10-30 12:48:18.639','2024-10-30 12:48:19.882'),(30,1,1,'2024-10-30 13:34:54.970','2024-10-30 13:34:57.609'),(31,1,1,'2024-10-30 13:35:49.871','2024-10-30 13:35:52.126'),(32,1,1,'2024-10-30 13:40:22.331','2024-10-30 13:40:25.771'),(33,1,1,'2024-10-30 13:40:52.816','2024-10-30 13:40:54.514'),(34,1,1,'2024-10-30 14:19:15.059','2024-10-30 14:19:35.187'),(35,1,1,'2024-10-30 14:21:29.297','2024-10-30 14:22:10.115'),(36,1,2,'2024-10-30 14:22:18.310','2024-10-30 14:22:31.479'),(37,1,1,'2024-10-30 14:26:54.134','2024-10-30 14:26:58.617'),(38,1,2,'2024-11-01 16:57:18.410','2024-11-01 16:57:34.681'),(39,1,2,'2024-11-01 17:04:48.766','2024-11-01 17:05:34.692'),(40,1,1,'2024-11-01 17:12:29.925','2024-11-01 17:12:33.151'),(41,1,1,'2024-11-01 17:28:25.694','2024-11-01 17:28:29.916'),(42,1,1,'2024-11-01 17:29:06.566','2024-11-01 17:29:08.748'),(43,1,1,'2024-11-01 17:30:20.458','2024-11-01 17:30:22.509'),(44,1,1,'2024-11-01 17:31:00.340','2024-11-01 17:31:02.087'),(45,1,1,'2024-11-01 17:31:35.922','2024-11-01 17:31:38.814'),(46,1,1,'2024-11-01 17:34:32.274','2024-11-01 17:34:34.613'),(47,1,1,'2024-11-01 17:34:40.862','2024-11-01 17:34:47.781'),(48,1,1,'2024-11-01 17:36:05.114','2024-11-01 17:36:07.251'),(49,1,1,'2024-11-01 17:36:34.422','2024-11-01 17:36:38.198'),(50,1,1,'2024-11-01 17:38:51.394','2024-11-01 17:38:53.301'),(51,1,1,'2024-11-01 17:39:19.006','2024-11-01 17:39:20.657'),(52,1,1,'2024-11-01 17:40:08.760','2024-11-01 17:40:10.540'),(53,1,1,'2024-11-01 17:41:02.200','2024-11-01 17:41:04.095'),(54,1,1,'2024-11-01 17:42:13.813','2024-11-01 17:42:15.719'),(55,1,1,'2024-11-01 17:42:38.428','2024-11-01 17:42:41.021'),(56,1,1,'2024-11-01 17:43:02.007','2024-11-01 17:43:06.522'),(57,1,1,'2024-11-01 17:46:02.466','2024-11-01 17:46:05.622'),(58,1,1,'2024-11-01 17:46:40.929','2024-11-01 17:46:50.801'),(59,1,1,'2024-11-01 17:47:57.564','2024-11-01 17:48:05.641'),(60,1,1,'2024-11-01 17:48:56.786','2024-11-01 17:49:16.052'),(61,1,2,'2024-11-01 18:13:40.804','2024-11-01 18:13:44.201'),(62,1,1,'2024-11-01 18:14:14.965','2024-11-01 18:14:17.188'),(63,1,1,'2024-11-01 18:14:30.496','2024-11-01 18:14:32.735'),(64,1,52,'2024-11-02 16:18:13.081','2024-11-02 16:18:27.895'),(65,1,1,'2024-11-02 17:56:07.943','2024-11-02 17:56:10.327'),(66,1,1,'2024-11-02 18:18:00.048','2024-11-02 18:18:01.878');
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
) ENGINE=InnoDB AUTO_INCREMENT=237 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practice_session_item`
--

LOCK TABLES `practice_session_item` WRITE;
/*!40000 ALTER TABLE `practice_session_item` DISABLE KEYS */;
INSERT INTO `practice_session_item` VALUES (1,1,1,1,'2024-10-22 15:10:10.000','2024-10-22 15:11:00.000'),(2,1,2,1,'2024-10-22 15:11:00.000','2024-10-22 15:12:05.000'),(3,1,3,1,'2024-10-22 15:12:05.000','2024-10-22 15:13:00.000'),(4,1,4,0,'2024-10-22 15:13:00.000','2024-10-22 15:15:00.000'),(9,4,1,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(10,4,2,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(11,4,3,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(12,4,4,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(13,5,1,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(14,5,2,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(15,5,3,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(16,5,4,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(17,6,1,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(18,6,2,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(19,6,3,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(20,6,4,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(22,8,11,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(23,8,10,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(24,8,9,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(25,8,8,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(26,12,11,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(27,12,10,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(28,12,9,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(29,12,8,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(30,13,11,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(31,13,10,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(32,13,9,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(33,13,8,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(34,14,11,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(35,14,10,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(36,14,9,1,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(37,14,8,1,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(38,17,1,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(39,17,2,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(40,17,3,0,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(41,17,4,0,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(45,20,5,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(46,20,6,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(47,20,7,0,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(48,20,8,0,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(49,21,5,1,'2024-10-22 16:10:00.000','2024-10-22 16:11:00.000'),(50,21,6,1,'2024-10-22 16:11:00.000','2024-10-22 16:12:00.000'),(51,21,7,0,'2024-10-22 16:12:00.000','2024-10-22 16:13:00.000'),(52,21,8,0,'2024-10-22 16:13:00.000','2024-10-22 16:14:00.000'),(53,22,1,1,'2024-10-30 11:46:21.515','2024-10-30 11:46:29.294'),(54,22,2,1,'2024-10-30 11:46:29.294','2024-10-30 11:46:31.980'),(55,22,3,0,'2024-10-30 11:46:31.980','2024-10-30 11:46:32.922'),(56,22,4,1,'2024-10-30 11:46:32.922','2024-10-30 11:46:36.309'),(57,23,1,1,'2024-10-30 11:53:04.540','2024-10-30 11:53:06.117'),(58,23,2,0,'2024-10-30 11:53:06.117','2024-10-30 11:53:06.398'),(59,23,3,1,'2024-10-30 11:53:06.398','2024-10-30 11:53:06.642'),(60,23,4,0,'2024-10-30 11:53:06.642','2024-10-30 11:53:06.857'),(61,24,1,1,'2024-10-30 11:56:47.600','2024-10-30 11:56:50.059'),(62,24,2,0,'2024-10-30 11:56:50.059','2024-10-30 11:56:50.404'),(63,24,3,1,'2024-10-30 11:56:50.404','2024-10-30 11:56:50.718'),(64,24,4,0,'2024-10-30 11:56:50.718','2024-10-30 11:56:51.084'),(65,25,1,1,'2024-10-30 12:33:08.044','2024-10-30 12:33:27.852'),(66,25,2,1,'2024-10-30 12:33:27.852','2024-10-30 12:33:44.373'),(67,25,3,0,'2024-10-30 12:33:44.373','2024-10-30 12:34:06.873'),(68,25,4,1,'2024-10-30 12:34:06.873','2024-10-30 12:34:16.414'),(69,26,1,1,'2024-10-30 12:40:15.261','2024-10-30 12:40:17.167'),(70,26,2,0,'2024-10-30 12:40:17.167','2024-10-30 12:40:17.690'),(71,26,3,1,'2024-10-30 12:40:17.690','2024-10-30 12:40:18.010'),(72,26,4,0,'2024-10-30 12:40:18.010','2024-10-30 12:40:18.626'),(73,27,1,1,'2024-10-30 12:44:20.378','2024-10-30 12:44:21.930'),(74,27,2,0,'2024-10-30 12:44:21.930','2024-10-30 12:44:22.281'),(75,27,3,1,'2024-10-30 12:44:22.281','2024-10-30 12:44:22.565'),(76,27,4,0,'2024-10-30 12:44:22.565','2024-10-30 12:44:22.836'),(77,28,1,0,'2024-10-30 12:47:11.588','2024-10-30 12:47:13.147'),(78,28,2,0,'2024-10-30 12:47:13.147','2024-10-30 12:47:13.285'),(79,28,3,0,'2024-10-30 12:47:13.285','2024-10-30 12:47:13.422'),(80,28,4,0,'2024-10-30 12:47:13.422','2024-10-30 12:47:13.554'),(81,29,1,0,'2024-10-30 12:48:18.639','2024-10-30 12:48:19.553'),(82,29,2,0,'2024-10-30 12:48:19.553','2024-10-30 12:48:19.629'),(83,29,3,0,'2024-10-30 12:48:19.629','2024-10-30 12:48:19.713'),(84,29,4,0,'2024-10-30 12:48:19.713','2024-10-30 12:48:19.882'),(85,30,1,1,'2024-10-30 13:34:54.970','2024-10-30 13:34:56.952'),(86,30,2,0,'2024-10-30 13:34:56.952','2024-10-30 13:34:57.198'),(87,30,3,1,'2024-10-30 13:34:57.198','2024-10-30 13:34:57.416'),(88,30,4,0,'2024-10-30 13:34:57.416','2024-10-30 13:34:57.609'),(89,31,1,1,'2024-10-30 13:35:49.871','2024-10-30 13:35:51.496'),(90,31,2,0,'2024-10-30 13:35:51.496','2024-10-30 13:35:51.706'),(91,31,3,1,'2024-10-30 13:35:51.706','2024-10-30 13:35:51.935'),(92,31,4,0,'2024-10-30 13:35:51.935','2024-10-30 13:35:52.126'),(93,32,1,1,'2024-10-30 13:40:22.331','2024-10-30 13:40:24.943'),(94,32,2,0,'2024-10-30 13:40:24.943','2024-10-30 13:40:25.189'),(95,32,3,1,'2024-10-30 13:40:25.189','2024-10-30 13:40:25.454'),(96,32,4,0,'2024-10-30 13:40:25.454','2024-10-30 13:40:25.771'),(97,33,1,0,'2024-10-30 13:40:52.816','2024-10-30 13:40:54.081'),(98,33,2,0,'2024-10-30 13:40:54.081','2024-10-30 13:40:54.215'),(99,33,3,0,'2024-10-30 13:40:54.215','2024-10-30 13:40:54.366'),(100,33,4,0,'2024-10-30 13:40:54.366','2024-10-30 13:40:54.514'),(101,34,1,1,'2024-10-30 14:19:15.059','2024-10-30 14:19:20.133'),(102,34,2,0,'2024-10-30 14:19:20.133','2024-10-30 14:19:21.969'),(103,34,3,1,'2024-10-30 14:19:21.969','2024-10-30 14:19:34.268'),(104,34,4,0,'2024-10-30 14:19:34.268','2024-10-30 14:19:35.187'),(105,35,1,0,'2024-10-30 14:21:29.297','2024-10-30 14:21:53.834'),(106,35,2,1,'2024-10-30 14:21:53.834','2024-10-30 14:21:59.635'),(107,35,3,1,'2024-10-30 14:21:59.635','2024-10-30 14:22:04.631'),(108,35,4,0,'2024-10-30 14:22:04.631','2024-10-30 14:22:10.115'),(109,36,5,1,'2024-10-30 14:22:18.310','2024-10-30 14:22:22.469'),(110,36,6,1,'2024-10-30 14:22:22.469','2024-10-30 14:22:24.288'),(111,36,7,1,'2024-10-30 14:22:24.288','2024-10-30 14:22:26.976'),(112,36,8,1,'2024-10-30 14:22:26.976','2024-10-30 14:22:29.891'),(113,36,90,1,'2024-10-30 14:22:29.891','2024-10-30 14:22:31.479'),(114,37,1,1,'2024-10-30 14:26:54.134','2024-10-30 14:26:57.287'),(115,37,2,0,'2024-10-30 14:26:57.287','2024-10-30 14:26:57.785'),(116,37,3,1,'2024-10-30 14:26:57.785','2024-10-30 14:26:58.171'),(117,37,4,0,'2024-10-30 14:26:58.171','2024-10-30 14:26:58.617'),(118,38,5,1,'2024-11-01 16:57:18.410','2024-11-01 16:57:22.842'),(119,38,6,1,'2024-11-01 16:57:22.842','2024-11-01 16:57:27.076'),(120,38,7,0,'2024-11-01 16:57:27.076','2024-11-01 16:57:28.972'),(121,38,8,1,'2024-11-01 16:57:28.972','2024-11-01 16:57:31.778'),(122,38,90,0,'2024-11-01 16:57:31.778','2024-11-01 16:57:34.681'),(123,39,5,0,'2024-11-01 17:04:48.766','2024-11-01 17:05:32.693'),(124,39,6,1,'2024-11-01 17:05:32.693','2024-11-01 17:05:33.556'),(125,39,7,0,'2024-11-01 17:05:33.556','2024-11-01 17:05:33.833'),(126,39,8,1,'2024-11-01 17:05:33.833','2024-11-01 17:05:34.194'),(127,39,90,0,'2024-11-01 17:05:34.194','2024-11-01 17:05:34.692'),(128,40,1,1,'2024-11-01 17:12:29.925','2024-11-01 17:12:31.889'),(129,40,2,0,'2024-11-01 17:12:31.889','2024-11-01 17:12:32.302'),(130,40,3,1,'2024-11-01 17:12:32.302','2024-11-01 17:12:32.680'),(131,40,4,0,'2024-11-01 17:12:32.680','2024-11-01 17:12:33.151'),(132,41,1,0,'2024-11-01 17:28:25.694','2024-11-01 17:28:27.884'),(133,41,2,1,'2024-11-01 17:28:27.884','2024-11-01 17:28:28.699'),(134,41,3,0,'2024-11-01 17:28:28.699','2024-11-01 17:28:29.340'),(135,41,4,1,'2024-11-01 17:28:29.340','2024-11-01 17:28:29.916'),(136,42,1,1,'2024-11-01 17:29:06.566','2024-11-01 17:29:07.739'),(137,42,2,0,'2024-11-01 17:29:07.739','2024-11-01 17:29:08.084'),(138,42,3,1,'2024-11-01 17:29:08.084','2024-11-01 17:29:08.393'),(139,42,4,0,'2024-11-01 17:29:08.393','2024-11-01 17:29:08.748'),(140,43,1,1,'2024-11-01 17:30:20.458','2024-11-01 17:30:21.544'),(141,43,2,1,'2024-11-01 17:30:21.544','2024-11-01 17:30:21.880'),(142,43,3,1,'2024-11-01 17:30:21.880','2024-11-01 17:30:22.249'),(143,43,4,1,'2024-11-01 17:30:22.249','2024-11-01 17:30:22.509'),(144,44,1,1,'2024-11-01 17:31:00.340','2024-11-01 17:31:01.397'),(145,44,2,0,'2024-11-01 17:31:01.397','2024-11-01 17:31:01.683'),(146,44,3,1,'2024-11-01 17:31:01.683','2024-11-01 17:31:01.882'),(147,44,4,0,'2024-11-01 17:31:01.882','2024-11-01 17:31:02.087'),(148,45,1,0,'2024-11-01 17:31:35.922','2024-11-01 17:31:37.978'),(149,45,2,1,'2024-11-01 17:31:37.978','2024-11-01 17:31:38.239'),(150,45,3,0,'2024-11-01 17:31:38.239','2024-11-01 17:31:38.480'),(151,45,4,1,'2024-11-01 17:31:38.480','2024-11-01 17:31:38.814'),(152,46,1,1,'2024-11-01 17:34:32.274','2024-11-01 17:34:33.837'),(153,46,2,0,'2024-11-01 17:34:33.837','2024-11-01 17:34:34.107'),(154,46,3,1,'2024-11-01 17:34:34.107','2024-11-01 17:34:34.338'),(155,46,4,0,'2024-11-01 17:34:34.338','2024-11-01 17:34:34.613'),(156,47,1,1,'2024-11-01 17:34:40.862','2024-11-01 17:34:43.263'),(157,47,2,0,'2024-11-01 17:34:43.263','2024-11-01 17:34:47.414'),(158,47,3,0,'2024-11-01 17:34:47.414','2024-11-01 17:34:47.582'),(159,47,4,0,'2024-11-01 17:34:47.582','2024-11-01 17:34:47.781'),(160,48,1,1,'2024-11-01 17:36:05.114','2024-11-01 17:36:06.165'),(161,48,2,0,'2024-11-01 17:36:06.165','2024-11-01 17:36:06.546'),(162,48,3,1,'2024-11-01 17:36:06.546','2024-11-01 17:36:06.994'),(163,48,4,0,'2024-11-01 17:36:06.994','2024-11-01 17:36:07.251'),(164,49,1,1,'2024-11-01 17:36:34.422','2024-11-01 17:36:37.064'),(165,49,2,0,'2024-11-01 17:36:37.064','2024-11-01 17:36:37.598'),(166,49,3,1,'2024-11-01 17:36:37.598','2024-11-01 17:36:37.873'),(167,49,4,0,'2024-11-01 17:36:37.873','2024-11-01 17:36:38.198'),(168,50,1,1,'2024-11-01 17:38:51.394','2024-11-01 17:38:52.271'),(169,50,2,0,'2024-11-01 17:38:52.271','2024-11-01 17:38:52.650'),(170,50,3,1,'2024-11-01 17:38:52.650','2024-11-01 17:38:52.938'),(171,50,4,0,'2024-11-01 17:38:52.938','2024-11-01 17:38:53.301'),(172,51,1,1,'2024-11-01 17:39:19.006','2024-11-01 17:39:19.921'),(173,51,2,0,'2024-11-01 17:39:19.921','2024-11-01 17:39:20.203'),(174,51,3,1,'2024-11-01 17:39:20.203','2024-11-01 17:39:20.447'),(175,51,4,0,'2024-11-01 17:39:20.447','2024-11-01 17:39:20.657'),(176,52,1,1,'2024-11-01 17:40:08.760','2024-11-01 17:40:09.819'),(177,52,2,0,'2024-11-01 17:40:09.819','2024-11-01 17:40:10.078'),(178,52,3,1,'2024-11-01 17:40:10.078','2024-11-01 17:40:10.333'),(179,52,4,0,'2024-11-01 17:40:10.333','2024-11-01 17:40:10.540'),(180,53,1,1,'2024-11-01 17:41:02.200','2024-11-01 17:41:03.314'),(181,53,2,0,'2024-11-01 17:41:03.314','2024-11-01 17:41:03.603'),(182,53,3,1,'2024-11-01 17:41:03.603','2024-11-01 17:41:03.870'),(183,53,4,0,'2024-11-01 17:41:03.870','2024-11-01 17:41:04.095'),(184,54,1,1,'2024-11-01 17:42:13.813','2024-11-01 17:42:14.900'),(185,54,2,0,'2024-11-01 17:42:14.900','2024-11-01 17:42:15.213'),(186,54,3,1,'2024-11-01 17:42:15.213','2024-11-01 17:42:15.477'),(187,54,4,0,'2024-11-01 17:42:15.477','2024-11-01 17:42:15.719'),(188,55,1,1,'2024-11-01 17:42:38.428','2024-11-01 17:42:39.546'),(189,55,2,0,'2024-11-01 17:42:39.546','2024-11-01 17:42:39.819'),(190,55,3,1,'2024-11-01 17:42:39.819','2024-11-01 17:42:40.889'),(191,55,4,1,'2024-11-01 17:42:40.889','2024-11-01 17:42:41.021'),(192,56,1,1,'2024-11-01 17:43:02.007','2024-11-01 17:43:03.378'),(193,56,2,1,'2024-11-01 17:43:03.378','2024-11-01 17:43:05.683'),(194,56,3,1,'2024-11-01 17:43:05.683','2024-11-01 17:43:06.361'),(195,56,4,1,'2024-11-01 17:43:06.361','2024-11-01 17:43:06.522'),(196,57,1,1,'2024-11-01 17:46:02.466','2024-11-01 17:46:03.965'),(197,57,2,0,'2024-11-01 17:46:03.965','2024-11-01 17:46:04.556'),(198,57,3,1,'2024-11-01 17:46:04.556','2024-11-01 17:46:05.080'),(199,57,4,0,'2024-11-01 17:46:05.080','2024-11-01 17:46:05.622'),(200,58,1,1,'2024-11-01 17:46:40.929','2024-11-01 17:46:43.898'),(201,58,2,0,'2024-11-01 17:46:43.898','2024-11-01 17:46:46.016'),(202,58,3,1,'2024-11-01 17:46:46.016','2024-11-01 17:46:48.092'),(203,58,4,0,'2024-11-01 17:46:48.092','2024-11-01 17:46:50.801'),(204,59,1,1,'2024-11-01 17:47:57.564','2024-11-01 17:47:59.991'),(205,59,2,0,'2024-11-01 17:47:59.991','2024-11-01 17:48:01.486'),(206,59,3,1,'2024-11-01 17:48:01.486','2024-11-01 17:48:02.938'),(207,59,4,1,'2024-11-01 17:48:02.938','2024-11-01 17:48:05.641'),(208,60,1,1,'2024-11-01 17:48:56.786','2024-11-01 17:49:15.464'),(209,60,2,0,'2024-11-01 17:49:15.464','2024-11-01 17:49:15.678'),(210,60,3,1,'2024-11-01 17:49:15.678','2024-11-01 17:49:15.854'),(211,60,4,0,'2024-11-01 17:49:15.854','2024-11-01 17:49:16.052'),(212,61,5,1,'2024-11-01 18:13:40.804','2024-11-01 18:13:42.178'),(213,61,6,0,'2024-11-01 18:13:42.178','2024-11-01 18:13:42.498'),(214,61,7,1,'2024-11-01 18:13:42.498','2024-11-01 18:13:42.767'),(215,61,8,0,'2024-11-01 18:13:42.767','2024-11-01 18:13:43.497'),(216,61,90,1,'2024-11-01 18:13:43.497','2024-11-01 18:13:44.201'),(217,62,1,0,'2024-11-01 18:14:14.965','2024-11-01 18:14:16.339'),(218,62,2,1,'2024-11-01 18:14:16.339','2024-11-01 18:14:16.670'),(219,62,3,0,'2024-11-01 18:14:16.670','2024-11-01 18:14:16.932'),(220,62,4,1,'2024-11-01 18:14:16.932','2024-11-01 18:14:17.188'),(221,63,1,1,'2024-11-01 18:14:30.496','2024-11-01 18:14:31.407'),(222,63,2,0,'2024-11-01 18:14:31.407','2024-11-01 18:14:31.938'),(223,63,3,1,'2024-11-01 18:14:31.938','2024-11-01 18:14:32.353'),(224,63,4,0,'2024-11-01 18:14:32.353','2024-11-01 18:14:32.735'),(225,64,91,0,'2024-11-02 16:18:13.081','2024-11-02 16:18:20.688'),(226,64,92,1,'2024-11-02 16:18:20.688','2024-11-02 16:18:21.342'),(227,64,93,0,'2024-11-02 16:18:21.342','2024-11-02 16:18:24.404'),(228,64,94,1,'2024-11-02 16:18:24.404','2024-11-02 16:18:27.895'),(229,65,1,1,'2024-11-02 17:56:07.943','2024-11-02 17:56:08.835'),(230,65,2,1,'2024-11-02 17:56:08.835','2024-11-02 17:56:09.195'),(231,65,3,0,'2024-11-02 17:56:09.195','2024-11-02 17:56:09.947'),(232,65,4,1,'2024-11-02 17:56:09.947','2024-11-02 17:56:10.327'),(233,66,1,1,'2024-11-02 18:18:00.048','2024-11-02 18:18:00.723'),(234,66,2,0,'2024-11-02 18:18:00.723','2024-11-02 18:18:01.032'),(235,66,3,1,'2024-11-02 18:18:01.032','2024-11-02 18:18:01.665'),(236,66,4,0,'2024-11-02 18:18:01.665','2024-11-02 18:18:01.878');
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
  CONSTRAINT `fk_practice_set_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `set_name` CHECK ((`set_name` <> _utf8mb4''))
) ENGINE=InnoDB AUTO_INCREMENT=102 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practice_set`
--

LOCK TABLES `practice_set` WRITE;
/*!40000 ALTER TABLE `practice_set` DISABLE KEYS */;
INSERT INTO `practice_set` VALUES (1,1,'pandas questions',NULL,NULL,0,0),(2,1,'systemd',NULL,'2024-10-23 17:24:17.000',1,0),(3,1,'math','2024-10-20 18:53:10.659','2024-10-20 18:53:10.659',0,0),(13,1,'new name','2024-10-20 19:27:05.375','2024-11-01 18:20:12.000',1,0),(21,2,'geo','2024-10-20 23:14:38.677','2024-10-22 14:28:28.000',1,0),(35,3,'ab','2024-10-21 12:57:48.015','2024-10-22 14:40:05.000',1,0),(36,1,'coolest set eveeeeeer','2024-10-21 12:57:51.422','2024-10-22 13:15:05.000',1,1),(39,1,'pawel','2024-10-21 13:01:25.562','2024-10-22 13:15:43.000',0,1),(40,1,'coolest set eveeeeeer','2024-10-21 13:04:38.525','2024-10-22 12:26:53.000',1,0),(41,1,'maths','2024-10-21 13:07:14.103','2024-10-22 14:39:56.000',1,0),(42,1,'maths','2024-10-21 13:07:36.050','2024-10-21 13:07:36.050',0,0),(43,1,'maths','2024-10-21 13:09:39.143','2024-10-21 13:09:39.143',0,0),(44,1,'maths','2024-10-21 13:17:01.222','2024-10-21 13:17:01.222',0,0),(45,1,'maths','2024-10-21 13:18:08.410','2024-10-22 12:27:53.000',0,0),(46,1,'maths','2024-10-21 13:43:37.505','2024-10-21 13:43:37.505',0,0),(47,1,'maths','2024-10-21 13:59:34.888','2024-10-21 13:59:34.888',0,0),(48,1,'maths','2024-10-21 13:59:40.969','2024-10-21 13:59:40.969',0,0),(49,1,'maths','2024-10-21 13:59:48.008','2024-10-21 13:59:48.008',0,0),(50,1,'sobb','2024-10-21 13:59:55.479','2024-10-21 13:59:55.479',1,0),(51,1,'hello world','2024-10-21 14:55:26.097','2024-10-22 10:15:36.000',0,1),(52,1,'neww','2024-10-27 17:10:21.801','2024-10-27 17:10:21.000',0,0),(65,1,'gfdgfdgfd','2024-10-27 18:19:13.228','2024-10-27 18:19:13.000',0,0),(66,1,'gfdgfdgfd','2024-10-27 18:19:13.549','2024-10-27 18:19:13.000',0,0),(67,1,'aaaa','2024-10-27 18:20:27.254','2024-11-01 18:22:46.000',1,0),(68,1,'aaaa','2024-10-27 18:20:27.600','2024-10-27 18:20:27.000',0,0),(69,1,'aaaaaaaaaaaaa','2024-10-27 18:21:38.041','2024-10-29 18:23:26.000',0,1),(70,1,'dsadsa','2024-10-27 18:24:10.721','2024-10-27 23:16:45.000',0,1),(71,1,'fsdfds','2024-10-27 18:25:30.549','2024-10-27 23:16:43.000',0,1),(72,1,'hello123','2024-10-27 18:32:19.524','2024-10-27 23:16:37.000',0,1),(73,1,'helloooo','2024-10-27 18:32:48.383','2024-10-27 23:16:34.000',0,1),(74,1,'fkjsdhgfkjdsgjk','2024-10-27 18:33:20.678','2024-10-27 23:16:39.000',0,1),(75,1,'dsahdlkjsadjkas','2024-10-27 19:09:59.510','2024-10-27 23:16:41.000',0,1),(76,1,'fdsfds','2024-10-27 19:10:12.294','2024-10-27 23:16:30.000',0,1),(79,1,'asdfadsf','2024-10-27 19:14:03.245','2024-10-27 23:16:32.000',0,1),(81,1,'gsgfsd','2024-10-27 19:14:34.811','2024-10-27 23:16:24.000',0,1),(82,1,'hgfhgf','2024-10-27 19:15:05.471','2024-10-27 23:16:26.000',0,1),(86,1,'gfdgfdgfd','2024-10-27 19:21:57.465','2024-10-27 23:16:28.000',0,1),(87,1,'hgfdhdfghgfd','2024-10-27 19:23:04.723','2024-10-27 23:16:47.000',0,1),(88,1,'hhhhhhh','2024-10-27 19:23:28.216','2024-10-27 23:14:02.000',0,1),(89,1,'gdfgdfgfd','2024-10-27 19:28:07.965','2024-10-27 20:08:08.000',0,0),(90,1,'hgfhfg','2024-10-27 19:30:12.983','2024-10-27 23:13:56.000',0,1),(91,1,'fsdfsdfsd','2024-10-27 19:33:00.337','2024-10-27 23:13:54.000',0,1),(92,1,'fsdfsd','2024-10-27 19:49:29.512','2024-10-27 23:07:20.000',0,1),(93,1,'fdsfdsfsdfsd','2024-10-27 19:49:42.493','2024-10-27 23:07:38.000',0,1),(94,1,'fdsfsdfsdfsd','2024-10-27 20:08:55.638','2024-10-27 23:13:50.000',0,1),(95,1,'abecede','2024-10-27 20:11:53.045','2024-10-27 23:13:44.000',0,1),(96,1,'fsdfsdf','2024-10-27 20:15:36.410','2024-10-27 23:13:48.000',1,1),(97,1,'aaaaaaaaa','2024-10-27 20:16:13.418','2024-10-27 23:11:55.000',1,1),(98,1,'fggfgfgf','2024-10-27 20:16:34.172','2024-10-27 23:08:04.000',1,1),(99,1,'ssssss','2024-10-27 20:18:57.809','2024-10-27 23:11:01.000',1,1),(100,1,'public set','2024-10-27 20:22:12.265','2024-10-30 14:18:34.000',0,1),(101,1,'Coolest questions ever','2024-10-27 23:16:03.817','2024-10-27 23:16:03.000',0,0);
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
  CONSTRAINT `fk_practice_set_item_set_id` FOREIGN KEY (`practice_set_id`) REFERENCES `practice_set` (`id`),
  CONSTRAINT `answer` CHECK ((`answer` <> _utf8mb4'')),
  CONSTRAINT `question` CHECK ((`question` <> _utf8mb3''))
) ENGINE=InnoDB AUTO_INCREMENT=147 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practice_set_item`
--

LOCK TABLES `practice_set_item` WRITE;
/*!40000 ALTER TABLE `practice_set_item` DISABLE KEYS */;
INSERT INTO `practice_set_item` VALUES (1,1,'How do you display basic information about a dataframe?','df.info()',NULL,0),(2,1,'How do you display the mean average for column Sales?','df[\"Sales\"].mean()',NULL,0),(3,1,'Set max columns displayed to 10','pd.display.max.columns = 10',NULL,0),(4,1,'Set max rows displayed to 15','pd.display.max.rows = 15',NULL,0),(5,2,'Start nginx?','systemctl start nginx',NULL,0),(6,2,'List all units?','systemctl list-all-units',NULL,0),(7,2,'Display logs for nginx?','journalctl -xue nginx',NULL,0),(8,2,'Reload daemons?','systemctl reload-daemons',NULL,0),(9,3,'2+2?','4',NULL,0),(10,3,'10+2?','12',NULL,0),(11,40,'sobczyk tu byl221222?','nie bylo',NULL,0),(12,40,'sobczyk tu byl tez?','no a jak 22122',NULL,0),(13,40,'sobczyk tu byl221222?fff','nie byloaaaaa',NULL,0),(15,41,'2+2?','4',NULL,0),(16,41,'10/2?','5',NULL,0),(17,41,'15*3?','45',NULL,0),(18,41,'10+2?','12',NULL,0),(19,42,'2+2?','4',NULL,0),(20,42,'10/2?','5',NULL,0),(21,42,'15*3?','45',NULL,0),(22,42,'10+2?','12',NULL,0),(23,43,'2+2?','4',NULL,0),(24,43,'10/2?','5',NULL,0),(25,43,'15*3?','45',NULL,0),(26,43,'10+2?','12',NULL,0),(27,44,'2+2?','4',NULL,0),(28,44,'10/2?','5',NULL,0),(29,44,'15*3?','45',NULL,0),(30,44,'10+2?','12',NULL,0),(31,45,'2+2?','4',NULL,1),(32,45,'10/2?','5',NULL,1),(33,45,'15*3?','45',NULL,0),(34,45,'10+2?','12',NULL,0),(35,46,'2+2?','4',NULL,0),(36,46,'10/2?','5',NULL,0),(37,46,'15*3?','45',NULL,0),(38,46,'10+2?','12',NULL,0),(39,47,'2+2?','4',NULL,0),(40,47,'10/2?','5',NULL,0),(41,47,'15*3?','45',NULL,0),(42,47,'10+2?','12',NULL,0),(43,48,'2+2?','4',NULL,0),(44,48,'10/2?','5',NULL,0),(45,48,'15*3?','45',NULL,0),(46,48,'10+2?','12',NULL,0),(47,49,'2+2?','4',NULL,0),(48,49,'10/2?','5',NULL,0),(49,49,'15*3?','45',NULL,0),(50,49,'10+2?','12',NULL,0),(51,50,'2+2?','4',NULL,0),(52,50,'10/2?','5',NULL,0),(53,50,'15*3?','45',NULL,0),(54,50,'10+2?','12',NULL,0),(55,51,'2+2?','4',NULL,0),(56,51,'10/2?','5',NULL,0),(57,51,'15*3?','45',NULL,0),(58,51,'10+2?','12',NULL,0),(59,40,'byl tu','no jak nie jak tak',NULL,0),(60,40,'have you ever?','nope',NULL,0),(61,40,'have you ever eaten?','yes',NULL,0),(68,40,'have you ever had a dog?','nope',NULL,0),(69,40,'have you ever eaten a sanwich?','yes',NULL,0),(72,40,'have you ever had a dog?','nope',NULL,0),(73,40,'have you ever eaten a sanwich?','yes',NULL,0),(74,40,'have you ever had a dog?','nope',NULL,0),(75,40,'have you ever eaten a sanwich?','yes',NULL,0),(76,40,'have you ever had a dog?','nope',NULL,0),(77,40,'have you ever eaten a sanwich?','yes',NULL,0),(78,40,'have you ever had a dog?','nope',NULL,0),(79,40,'have you ever eaten a sanwich?','yes',NULL,0),(80,40,'have you ever had a dog?','nope',NULL,0),(81,40,'have you ever eaten a sanwich?','yes',NULL,0),(82,40,'have you ever had a dog?','nope',NULL,0),(83,40,'have you ever eaten a sanwich?','yes',NULL,0),(84,40,'have you ever had a dog?','nope',NULL,0),(85,40,'have you ever eaten a sanwich?','yes',NULL,0),(86,40,'have you ever had a dog?','nope',NULL,0),(87,40,'have you ever eaten a sanwich?','yes',NULL,0),(88,36,'have you ever had a dog?','nope',NULL,0),(89,36,'have you ever eaten a sanwich?','yes',NULL,0),(90,2,'bla bla','ble ble',NULL,0),(91,52,'2+2?','4',NULL,0),(92,52,'10/2?','5',NULL,0),(93,52,'15*3?','45',NULL,0),(94,52,'10+2?','12',NULL,0),(95,65,'gfdgfd','gfdgfdgfd',NULL,0),(96,65,'gfdg','fdgfdgfd',NULL,0),(97,66,'gfdgfd','gfdgfdgfd',NULL,0),(98,67,'aaaaaaa','aa',NULL,0),(99,67,'aaa','aaa',NULL,0),(100,68,'aaaaaaa','aa',NULL,0),(101,69,'fsdfsd','fdsfsdfsd',NULL,0),(102,70,'fdgfdsfsd','fsdfsdf',NULL,0),(103,70,'sfdsf','sfsdfsd',NULL,0),(104,71,'fsdfds','fsdfsdfsd',NULL,0),(105,72,'sdlkfhjsldkjfhsdjklhf','jkfhsdgjkflgsdjkl',NULL,0),(106,72,'fjksdgfjhsdkg','fsdhjgkgfsdjk',NULL,0),(107,73,'fhjsgdfhjksdgfhjk','fghjkdsgvfkhjsdgjhk',NULL,0),(108,73,'fghsdjkgfhjsdkg','jkfgsdhjkvcf',NULL,0),(109,74,'fhsdjgfhsdjkvgcjhkg','fhjksdvbhcjh',NULL,0),(110,74,'jfjhsdkxvckjh','fjkhsdvbchjkxszvc',NULL,0),(111,74,'jklcxzhjkcvkj','hjkvcsxzkhj\r\n',NULL,0),(112,75,'fhdksjlfgsdhjfkg','kjhgdfsahfjkgdsa',NULL,0),(113,75,'jhcfkdsgfchjksdg','jkchsxgjkchv',NULL,0),(114,75,'jkchxvszckhjasv','jhkcsxjhkcvasjkh',NULL,0),(115,75,'hcjvxszhjkcvjk','chjxsvbcjhk',NULL,0),(116,76,'fsdfsdf','sdfds',NULL,0),(117,76,'fsdf','dsfds',NULL,0),(120,79,'fafadsf','asdfadsfdas',NULL,0),(123,81,'gfsdg','fsdgfdsgfsd',NULL,0),(134,92,'fdsfsdf','sdfsdfsd',NULL,0),(135,92,'fsdfsdfsd','fdsfsd',NULL,0),(136,93,'fsdfsdf','sdfsdfsdfds',NULL,0),(137,94,'fsdfsd','fsdfsdfsd',NULL,0),(138,95,'aaaa','aaaa',NULL,0),(139,96,'fdsfsd','fsdfsdfds',NULL,0),(140,97,'aaaaaaa','bbbbbbb',NULL,0),(141,98,'hffff','fffff',NULL,0),(142,99,'fdsfds','fdsfdsfsd',NULL,0),(143,100,'elo','elo',NULL,0),(144,101,'How do you handle critical incidents?','By chillin',NULL,0),(145,101,'How would you describe your attitude?','Very well',NULL,0),(146,101,'What\'s the capital of France?','Paris',NULL,0);
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
-- Temporary view structure for view `v_practice_session_items`
--

DROP TABLE IF EXISTS `v_practice_session_items`;
/*!50001 DROP VIEW IF EXISTS `v_practice_session_items`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_practice_session_items` AS SELECT 
 1 AS `practice_session_id`,
 1 AS `user_id`,
 1 AS `question`,
 1 AS `answer`,
 1 AS `user_answer`,
 1 AS `time_started`,
 1 AS `time_ended`,
 1 AS `set_name`,
 1 AS `duration`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_practice_session_total_score`
--

DROP TABLE IF EXISTS `v_practice_session_total_score`;
/*!50001 DROP VIEW IF EXISTS `v_practice_session_total_score`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_practice_session_total_score` AS SELECT 
 1 AS `id`,
 1 AS `user_id`,
 1 AS `set_owner`,
 1 AS `private`,
 1 AS `set_name`,
 1 AS `answers_correct`,
 1 AS `answers_total`,
 1 AS `time_ended`,
 1 AS `answers_correct_percent`,
 1 AS `duration`*/;
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
 1 AS `item_id`,
 1 AS `question`,
 1 AS `answer`,
 1 AS `user_id`,
 1 AS `username`,
 1 AS `set_name`,
 1 AS `created_timestamp`,
 1 AS `last_edited_timestamp`,
 1 AS `private`,
 1 AS `is_deleted`,
 1 AS `set_is_deleted`*/;
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
-- Final view structure for view `v_practice_session_items`
--

/*!50001 DROP VIEW IF EXISTS `v_practice_session_items`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_practice_session_items` AS select `i`.`practice_session_id` AS `practice_session_id`,`s`.`user_id` AS `user_id`,`pi`.`question` AS `question`,`pi`.`answer` AS `answer`,`i`.`user_answer` AS `user_answer`,`i`.`time_started` AS `time_started`,`i`.`time_ended` AS `time_ended`,`ps`.`set_name` AS `set_name`,concat(time_format(sec_to_time(timestampdiff(SECOND,`i`.`time_started`,`i`.`time_ended`)),'%H:%i:%s'),'.',lpad(floor(((timestampdiff(MICROSECOND,`i`.`time_started`,`i`.`time_ended`) % 1000000) / 10000)),2,'0')) AS `duration` from (((`practice_session_item` `i` join `practice_session` `s` on((`i`.`practice_session_id` = `s`.`id`))) join `practice_set_item` `pi` on((`i`.`item_id` = `pi`.`id`))) join `practice_set` `ps` on((`s`.`practice_set_id` = `ps`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

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
/*!50001 VIEW `v_practice_session_total_score` AS select `ses`.`id` AS `id`,`ses`.`user_id` AS `user_id`,`pset`.`user_id` AS `set_owner`,`pset`.`private` AS `private`,`pset`.`set_name` AS `set_name`,sum(`item`.`user_answer`) AS `answers_correct`,count(`item`.`id`) AS `answers_total`,`ses`.`time_ended` AS `time_ended`,round(((sum(`item`.`user_answer`) / count(`item`.`id`)) * 100),0) AS `answers_correct_percent`,time_format(sec_to_time(timestampdiff(SECOND,`ses`.`time_started`,`ses`.`time_ended`)),'%H:%i:%s') AS `duration` from ((`practice_session` `ses` join `practice_session_item` `item` on((`ses`.`id` = `item`.`practice_session_id`))) join `practice_set` `pset` on((`ses`.`practice_set_id` = `pset`.`id`))) group by `ses`.`id` */;
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
/*!50001 VIEW `v_set_questions_all_info` AS select `s`.`id` AS `id`,`i`.`id` AS `item_id`,`i`.`question` AS `question`,`i`.`answer` AS `answer`,`s`.`user_id` AS `user_id`,`u`.`username` AS `username`,`s`.`set_name` AS `set_name`,`s`.`created_timestamp` AS `created_timestamp`,`s`.`last_edited_timestamp` AS `last_edited_timestamp`,`s`.`private` AS `private`,`i`.`is_deleted` AS `is_deleted`,`s`.`is_deleted` AS `set_is_deleted` from ((`practice_set_item` `i` join `practice_set` `s` on((`s`.`id` = `i`.`practice_set_id`))) join `users` `u` on((`u`.`id` = `s`.`user_id`))) */;
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

-- Dump completed on 2024-11-08 12:28:17
