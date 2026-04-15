-- MySQL dump 10.13  Distrib 8.0.33, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: smart_fishery_db
-- ------------------------------------------------------
-- Server version	8.0.44

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
-- Table structure for table `alarms`
--

DROP TABLE IF EXISTS `alarms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alarms` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '告警编号',
  `alarm_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '告警类型（水质告警、设备报警、系统告警）',
  `pond_id` int DEFAULT NULL COMMENT '相关的鱼池编号',
  `device_id` int DEFAULT NULL COMMENT '相关的设备编号',
  `severity` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '中' COMMENT '告警等级（低、中、高、严重）',
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '告警消息内容',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '未处理' COMMENT '告警状态（未处理、处理中、已处理、已忽略）',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '告警产生时间',
  `resolved_at` datetime DEFAULT NULL COMMENT '告警解决时间',
  PRIMARY KEY (`id`),
  KEY `device_id` (`device_id`),
  KEY `idx_alarm_type` (`alarm_type`),
  KEY `idx_pond_id` (`pond_id`),
  KEY `idx_severity` (`severity`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `alarms_ibfk_1` FOREIGN KEY (`pond_id`) REFERENCES `ponds` (`id`) ON DELETE SET NULL,
  CONSTRAINT `alarms_ibfk_2` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='告警事件表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alarms`
--

/*!40000 ALTER TABLE `alarms` DISABLE KEYS */;
/*!40000 ALTER TABLE `alarms` ENABLE KEYS */;

--
-- Table structure for table `device_control_rules`
--

DROP TABLE IF EXISTS `device_control_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `device_control_rules` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '规则编号',
  `rule_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '规则名称（如"溶氧过低自动增氧"）',
  `pond_id` int NOT NULL COMMENT '适用的鱼池编号',
  `device_id` int NOT NULL COMMENT '要控制的设备编号',
  `trigger_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '触发条件类型（dissolved_oxygen、temperature、ph_value等）',
  `trigger_threshold_min` float DEFAULT NULL COMMENT '触发最小阈值',
  `trigger_threshold_max` float DEFAULT NULL COMMENT '触发最大阈值',
  `action_on_trigger` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '触发时执行的动作（如"开启"、"关闭"）',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '规则是否启用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '规则创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_pond_id` (`pond_id`),
  KEY `idx_device_id` (`device_id`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `device_control_rules_ibfk_1` FOREIGN KEY (`pond_id`) REFERENCES `ponds` (`id`) ON DELETE CASCADE,
  CONSTRAINT `device_control_rules_ibfk_2` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='设备自动化控制规则表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_control_rules`
--

/*!40000 ALTER TABLE `device_control_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `device_control_rules` ENABLE KEYS */;

--
-- Table structure for table `device_logs`
--

DROP TABLE IF EXISTS `device_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `device_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志唯一编号，自增',
  `device_id` int NOT NULL COMMENT '关联的设备编号(devices.id)',
  `pond_id` int NOT NULL COMMENT '关联的鱼池编号(ponds.id)',
  `action` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '执行的具体动作（如"开启"、"关闭"、"报警"、"自动触发"）',
  `operator` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作来源（如"admin手动"、"系统自动触发"、"自动化规则"）',
  `previous_state` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作前设备状态',
  `current_state` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作后设备状态',
  `details` text COLLATE utf8mb4_unicode_ci COMMENT '详细描述信息',
  `log_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '操作或事件发生时间',
  PRIMARY KEY (`id`),
  KEY `idx_device_id` (`device_id`),
  KEY `idx_pond_id` (`pond_id`),
  KEY `idx_log_time` (`log_time`),
  KEY `idx_action` (`action`),
  CONSTRAINT `device_logs_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `device_logs_ibfk_2` FOREIGN KEY (`pond_id`) REFERENCES `ponds` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='设备操作与告警日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_logs`
--

/*!40000 ALTER TABLE `device_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `device_logs` ENABLE KEYS */;

--
-- Table structure for table `devices`
--

DROP TABLE IF EXISTS `devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `devices` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '设备唯一编号，自增',
  `pond_id` int NOT NULL COMMENT '设备对应所在的鱼池编号',
  `device_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '设备名称（如"1号增氧机"）',
  `device_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '设备类型（增氧机、投喂机、水泵、温控等）',
  `device_model` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '设备型号规格',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '离线' COMMENT '当前运行状态（在线、离线、运行、停止、故障）',
  `power_consumption` float DEFAULT '0' COMMENT '额定功率（瓦特）',
  `last_active` datetime DEFAULT NULL COMMENT '设备最后一次心跳或活跃时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '设备添加时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '设备信息最后更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_pond_id` (`pond_id`),
  KEY `idx_device_type` (`device_type`),
  KEY `idx_status` (`status`),
  KEY `idx_last_active` (`last_active`),
  CONSTRAINT `devices_ibfk_1` FOREIGN KEY (`pond_id`) REFERENCES `ponds` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='硬件设备信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devices`
--

/*!40000 ALTER TABLE `devices` DISABLE KEYS */;
/*!40000 ALTER TABLE `devices` ENABLE KEYS */;

--
-- Table structure for table `ponds`
--

DROP TABLE IF EXISTS `ponds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ponds` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '鱼池唯一编号，自增',
  `pond_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鱼池名称（如"一号池"）',
  `fish_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '养殖鱼类种类（如"草鱼"、"鲈鱼"）',
  `fish_count` int DEFAULT '0' COMMENT '当前鱼类估计数量（尾）',
  `volume` float DEFAULT '0' COMMENT '鱼池体积容量（立方米）',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '正常' COMMENT '鱼池状态（如"正常"、"维护中"、"空闲"）',
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鱼池位置描述',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录最后更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `pond_name` (`pond_name`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鱼池基本信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ponds`
--

/*!40000 ALTER TABLE `ponds` DISABLE KEYS */;
INSERT INTO `ponds` VALUES (1,'一号池','草鱼',3500,500,'正常','北区001','2026-04-11 04:33:44','2026-04-11 04:33:44'),(2,'二号池','鲈鱼',2800,400,'正常','北区002','2026-04-11 04:33:44','2026-04-11 04:33:44'),(3,'三号池','鲶鱼',4200,600,'维护中','中区001','2026-04-11 04:33:44','2026-04-11 04:33:44'),(4,'四号池','鲤鱼',3000,450,'正常','中区002','2026-04-11 04:33:44','2026-04-11 04:33:44'),(5,'五号池','鳙鱼',2500,350,'正常','南区001','2026-04-11 04:33:44','2026-04-11 04:33:44');
/*!40000 ALTER TABLE `ponds` ENABLE KEYS */;

--
-- Table structure for table `sensor_data`
--

DROP TABLE IF EXISTS `sensor_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sensor_data` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '数据记录唯一编号，自增',
  `pond_id` int NOT NULL COMMENT '关联的鱼池编号(ponds.id)',
  `temperature` float DEFAULT NULL COMMENT '水温（℃）',
  `ph_value` float DEFAULT NULL COMMENT '水体pH值',
  `dissolved_oxygen` float DEFAULT NULL COMMENT '溶解氧浓度（mg/L）',
  `salinity` float DEFAULT NULL COMMENT '盐度（‰）',
  `ammonia_nitrogen` float DEFAULT NULL COMMENT '氨氮含量（mg/L）',
  `nitrite_nitrogen` float DEFAULT NULL COMMENT '亚硝酸盐（mg/L）',
  `recorded_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '传感器数据采集时间',
  PRIMARY KEY (`id`),
  KEY `idx_pond_id` (`pond_id`),
  KEY `idx_recorded_at` (`recorded_at`),
  KEY `idx_pond_recorded` (`pond_id`,`recorded_at`),
  CONSTRAINT `sensor_data_ibfk_1` FOREIGN KEY (`pond_id`) REFERENCES `ponds` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=684 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='传感器水质监测数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sensor_data`
--

/*!40000 ALTER TABLE `sensor_data` DISABLE KEYS */;
INSERT INTO `sensor_data` VALUES (679,1,0.1,7,46,14.5,0,0,'2026-04-11 12:41:17'),(680,2,25.69,7.06,7.45,15.61,2.64,1.05,'2026-04-11 04:33:44'),(681,3,23.59,8.03,8.84,17.06,3.54,1.39,'2026-04-11 04:33:44'),(682,4,24.1,7.37,8.51,14.49,3.18,1.13,'2026-04-11 04:33:44'),(683,5,26.63,7.91,8.13,16.45,3.02,1.69,'2026-04-11 04:33:44');
/*!40000 ALTER TABLE `sensor_data` ENABLE KEYS */;

--
-- Table structure for table `system_logs`
--

DROP TABLE IF EXISTS `system_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志编号',
  `user_id` int DEFAULT NULL COMMENT '执行操作的用户编号',
  `action` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '执行的操作名称',
  `resource_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作涉及的资源类型（如pond、device、user）',
  `resource_id` int DEFAULT NULL COMMENT '操作涉及的资源编号',
  `details` text COLLATE utf8mb4_unicode_ci COMMENT '操作详细信息',
  `ip_address` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '操作来源IP地址',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '操作执行时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_resource_type` (`resource_type`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `system_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统操作日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_logs`
--

/*!40000 ALTER TABLE `system_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_logs` ENABLE KEYS */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '用户唯一编号',
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（登录用）',
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户邮箱',
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希值（bcrypt加密）',
  `full_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户真实姓名',
  `role` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'operator' COMMENT '用户角色（admin管理员、operator操作员、viewer观察员）',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '用户账号是否激活',
  `last_login` datetime DEFAULT NULL COMMENT '上次登录时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '账号创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '账号最后更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_role` (`role`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户管理表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin@smartfishery.com','$2b$12$WQQSsJ0B8h/sj8i8sj8i8ejXmM5DK5DK5DK5DK5DK','系统管理员','admin',1,NULL,'2026-03-14 14:32:32','2026-03-14 14:32:32'),(2,'operator001','op001@smartfishery.com','$2b$12$WQQSsJ0B8h/sj8i8sj8i8ejXmM5DK5DK5DK5DK5DK','渔场操作员','operator',1,NULL,'2026-03-14 14:32:32','2026-03-14 14:32:32'),(3,'viewer001','view001@smartfishery.com','$2b$12$WQQSsJ0B8h/sj8i8sj8i8ejXmM5DK5DK5DK5DK5DK','数据观察员','viewer',1,NULL,'2026-03-14 14:32:32','2026-03-14 14:32:32');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

--
-- Dumping routines for database 'smart_fishery_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-11 18:08:52
