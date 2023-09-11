-- MySQL dump 10.13  Distrib 8.0.26, for Win64 (x86_64)
--
-- Host: localhost    Database: budget
-- ------------------------------------------------------
-- Server version	8.0.26

--
-- DATABASE set-up
--
DROP DATABASE IF EXISTS budget;
CREATE DATABASE budget;
USE budget;

--
-- Table structure for table `places`
--

DROP TABLE IF EXISTS `places`;
CREATE TABLE `places` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `rating` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_place_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `places`
--

LOCK TABLES `places` WRITE;
INSERT INTO `places` VALUES (1,'Loon',5),(2,'Dranken Geers',3),(3,'Irish Pub',4);
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
INSERT INTO `users` VALUES (1,'Thomas Aelbrecht'),(2,'Pieter Van Der Helst'),(3,'Karine Samyn');
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
CREATE TABLE `transactions` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `amount` int NOT NULL,
  `date` datetime NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `place_id` int UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_transaction_user` (`user_id`),
  KEY `fk_transaction_place` (`place_id`),
  CONSTRAINT `fk_transaction_place` FOREIGN KEY (`place_id`) REFERENCES `places` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_transaction_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
INSERT INTO `transactions` VALUES (1,3500,'2021-05-25 19:40:00',1,1),(2,-220,'2021-05-08 20:00:00',1,2),(3,-74,'2021-05-21 14:30:00',1,3),(4,4000,'2021-05-25 19:40:00',2,1),(5,-220,'2021-05-09 23:00:00',2,2),(6,-74,'2021-05-22 12:00:00',2,3),(7,4000,'2021-05-25 19:40:00',3,1),(8,-220,'2021-05-10 10:00:00',3,2),(9,-74,'2021-05-19 11:30:00',3,3);
UNLOCK TABLES;

-- Dump completed on 2021-10-25 12:23:58
