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
) ENGINE=InnoDB AUTO_INCREMENT=221 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='设备操作与告警日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_logs`
--

/*!40000 ALTER TABLE `device_logs` DISABLE KEYS */;
INSERT INTO `device_logs` VALUES (189,104,29,'故障检修','admin手动','停止','运行中','一号池-增氧机1已执行操作','2026-04-17 13:19:10'),(190,104,29,'故障检修','系统自动触发','停止','运行中','一号池-增氧机1已执行操作','2026-04-16 09:19:10'),(191,104,29,'报警','系统自动触发','停止','运行中','一号池-增氧机1已执行操作','2026-04-17 08:19:10'),(192,104,29,'报警','admin手动','停止','运行中','一号池-增氧机1已执行操作','2026-04-18 00:19:10'),(193,105,29,'开启','系统自动触发','停止','运行中','一号池-增氧机2已执行操作','2026-04-17 16:19:10'),(194,105,29,'故障检修','admin手动','停止','运行中','一号池-增氧机2已执行操作','2026-04-17 18:19:10'),(195,105,29,'故障检修','admin手动','停止','运行中','一号池-增氧机2已执行操作','2026-04-18 02:19:10'),(196,105,29,'开启','admin手动','停止','运行中','一号池-增氧机2已执行操作','2026-04-16 16:19:10'),(197,105,29,'报警','admin手动','停止','运行中','一号池-增氧机2已执行操作','2026-04-16 19:19:10'),(198,106,29,'故障检修','admin手动','停止','运行中','一号池-增氧机3已执行操作','2026-04-16 11:19:10'),(199,106,29,'报警','admin手动','停止','运行中','一号池-增氧机3已执行操作','2026-04-16 18:19:10'),(200,106,29,'自动触发','admin手动','停止','运行中','一号池-增氧机3已执行操作','2026-04-16 14:19:10'),(201,107,29,'关闭','admin手动','停止','运行中','一号池-投喂机1已执行操作','2026-04-17 14:19:10'),(202,107,29,'自动触发','admin手动','停止','运行中','一号池-投喂机1已执行操作','2026-04-18 04:19:10'),(203,107,29,'自动触发','系统自动触发','停止','运行中','一号池-投喂机1已执行操作','2026-04-17 13:19:10'),(204,108,29,'开启','admin手动','停止','运行中','一号池-投喂机2已执行操作','2026-04-17 17:19:10'),(205,108,29,'报警','admin手动','停止','运行中','一号池-投喂机2已执行操作','2026-04-17 03:19:10'),(206,108,29,'报警','admin手动','停止','运行中','一号池-投喂机2已执行操作','2026-04-17 20:19:10'),(207,109,29,'开启','系统自动触发','停止','运行中','一号池-水泵1已执行操作','2026-04-16 09:19:10'),(208,109,29,'自动触发','系统自动触发','停止','运行中','一号池-水泵1已执行操作','2026-04-16 16:19:10'),(209,109,29,'故障检修','admin手动','停止','运行中','一号池-水泵1已执行操作','2026-04-17 18:19:10'),(210,110,30,'报警','admin手动','停止','运行中','二号池-增氧机1已执行操作','2026-04-18 04:19:10'),(211,110,30,'开启','admin手动','停止','运行中','二号池-增氧机1已执行操作','2026-04-17 23:19:10'),(212,110,30,'关闭','系统自动触发','停止','运行中','二号池-增氧机1已执行操作','2026-04-18 08:19:10'),(213,111,30,'关闭','系统自动触发','停止','运行中','二号池-增氧机2已执行操作','2026-04-17 06:19:10'),(214,111,30,'自动触发','admin手动','停止','运行中','二号池-增氧机2已执行操作','2026-04-17 22:19:10'),(215,111,30,'关闭','系统自动触发','停止','运行中','二号池-增氧机2已执行操作','2026-04-17 02:19:10'),(216,111,30,'故障检修','admin手动','停止','运行中','二号池-增氧机2已执行操作','2026-04-17 16:19:10'),(217,112,30,'故障检修','admin手动','停止','运行中','二号池-投喂机1已执行操作','2026-04-17 12:19:10'),(218,112,30,'报警','系统自动触发','停止','运行中','二号池-投喂机1已执行操作','2026-04-17 16:19:10'),(219,113,30,'关闭','admin手动','停止','运行中','二号池-水泵1已执行操作','2026-04-17 23:19:10'),(220,113,30,'关闭','系统自动触发','停止','运行中','二号池-水泵1已执行操作','2026-04-17 20:19:10');
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
) ENGINE=InnoDB AUTO_INCREMENT=132 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='硬件设备信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devices`
--

/*!40000 ALTER TABLE `devices` DISABLE KEYS */;
INSERT INTO `devices` VALUES (104,29,'一号池-增氧机1','增氧机','标准型','在线',750,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(105,29,'一号池-增氧机2','增氧机','标准型','在线',750,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(106,29,'一号池-增氧机3','增氧机','标准型','在线',750,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(107,29,'一号池-投喂机1','投喂机','自动型','在线',500,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(108,29,'一号池-投喂机2','投喂机','自动型','在线',500,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(109,29,'一号池-水泵1','水泵','节能型','离线',1100,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(110,30,'二号池-增氧机1','增氧机','标准型','在线',750,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(111,30,'二号池-增氧机2','增氧机','标准型','在线',750,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(112,30,'二号池-投喂机1','投喂机','自动型','在线',500,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(113,30,'二号池-水泵1','水泵','节能型','在线',1100,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(114,30,'二号池-水泵2','水泵','节能型','在线',1100,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(115,31,'三号池-增氧机1','增氧机','标准型','在线',750,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(116,31,'三号池-增氧机2','增氧机','标准型','在线',750,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(117,31,'三号池-增氧机3','增氧机','标准型','在线',750,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(118,31,'三号池-投喂机1','投喂机','自动型','在线',500,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(119,31,'三号池-投喂机2','投喂机','自动型','在线',500,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(120,31,'三号池-水泵1','水泵','节能型','在线',1100,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(121,31,'三号池-水泵2','水泵','节能型','在线',1100,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(122,32,'四号池-增氧机1','增氧机','标准型','在线',750,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(123,32,'四号池-增氧机2','增氧机','标准型','离线',750,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(124,32,'四号池-投喂机1','投喂机','自动型','离线',500,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(125,32,'四号池-投喂机2','投喂机','自动型','在线',500,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(126,32,'四号池-水泵1','水泵','节能型','离线',1100,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(127,32,'四号池-水泵2','水泵','节能型','在线',1100,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(128,33,'五号池-增氧机1','增氧机','标准型','在线',750,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(129,33,'五号池-增氧机2','增氧机','标准型','在线',750,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(130,33,'五号池-投喂机1','投喂机','自动型','在线',500,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10'),(131,33,'五号池-水泵1','水泵','节能型','在线',1100,'2026-04-18 09:19:10','2026-04-18 09:19:10','2026-04-18 09:19:10');
/*!40000 ALTER TABLE `devices` ENABLE KEYS */;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '订单项唯一编号',
  `order_id` int NOT NULL COMMENT '订单编号',
  `product_id` int NOT NULL COMMENT '产品编号',
  `quantity` int NOT NULL DEFAULT '0' COMMENT '采购数量（尾）',
  `unit_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '单价（元/尾）',
  `subtotal` decimal(12,2) GENERATED ALWAYS AS ((`quantity` * `unit_price`)) STORED COMMENT '小计（自动计算）',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`),
  CONSTRAINT `fk_item_order` FOREIGN KEY (`order_id`) REFERENCES `purchase_orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_item_product` FOREIGN KEY (`product_id`) REFERENCES `seedling_products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='采购订单详情表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `quantity`, `unit_price`, `created_at`) VALUES (1,1,1,884,0.80,'2026-04-18 09:19:10'),(2,1,2,534,1.50,'2026-04-18 09:19:10'),(3,1,2,870,1.50,'2026-04-18 09:19:10'),(4,2,4,370,1.20,'2026-04-18 09:19:10'),(5,2,3,202,2.00,'2026-04-18 09:19:10'),(6,3,1,531,0.80,'2026-04-18 09:19:10'),(7,3,1,688,0.80,'2026-04-18 09:19:10'),(8,4,6,545,1.80,'2026-04-18 09:19:10'),(9,4,6,151,1.80,'2026-04-18 09:19:10'),(10,4,5,217,0.60,'2026-04-18 09:19:10'),(11,5,1,101,0.80,'2026-04-18 09:19:10'),(12,5,2,154,1.50,'2026-04-18 09:19:10'),(13,6,2,989,1.50,'2026-04-18 09:19:10'),(14,6,1,313,0.80,'2026-04-18 09:19:10'),(15,7,6,153,1.80,'2026-04-18 09:19:10'),(16,7,6,455,1.80,'2026-04-18 09:19:10'),(17,8,6,768,1.80,'2026-04-18 09:19:10'),(18,8,5,787,0.60,'2026-04-18 09:19:10'),(19,8,5,852,0.60,'2026-04-18 09:19:10'),(20,8,5,199,0.60,'2026-04-18 09:19:10'),(21,9,4,282,1.20,'2026-04-18 09:19:10'),(22,9,3,810,2.00,'2026-04-18 09:19:10'),(23,10,5,896,0.60,'2026-04-18 09:19:10'),(24,10,6,417,1.80,'2026-04-18 09:19:10'),(25,10,5,712,0.60,'2026-04-18 09:19:10');
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;

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
  `default_supplier_id` int DEFAULT NULL COMMENT '常用供应商编号',
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鱼池位置描述',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录最后更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `pond_name` (`pond_name`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `fk_pond_default_supplier` (`default_supplier_id`),
  CONSTRAINT `fk_pond_default_supplier` FOREIGN KEY (`default_supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鱼池基本信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ponds`
--

/*!40000 ALTER TABLE `ponds` DISABLE KEYS */;
INSERT INTO `ponds` VALUES (29,'一号池','草鱼',3500,500,'正常',NULL,'北区001','2026-04-18 09:19:10','2026-04-18 09:19:10'),(30,'二号池','鲈鱼',2800,400,'正常',NULL,'北区002','2026-04-18 09:19:10','2026-04-18 09:19:10'),(31,'三号池','鲶鱼',4200,600,'维护中',NULL,'中区001','2026-04-18 09:19:10','2026-04-18 09:19:10'),(32,'四号池','鲤鱼',3000,450,'正常',NULL,'中区002','2026-04-18 09:19:10','2026-04-18 09:19:10'),(33,'五号池','鳙鱼',2500,350,'正常',NULL,'南区001','2026-04-18 09:19:10','2026-04-18 09:19:10');
/*!40000 ALTER TABLE `ponds` ENABLE KEYS */;

--
-- Table structure for table `purchase_orders`
--

DROP TABLE IF EXISTS `purchase_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_orders` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '采购订单唯一编号',
  `supplier_id` int NOT NULL COMMENT '供应商编号',
  `pond_id` int NOT NULL COMMENT '目标鱼池编号',
  `created_by` int NOT NULL COMMENT '创建者用户编号',
  `order_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '订单下单时间',
  `expected_delivery_date` date DEFAULT NULL COMMENT '预期交货日期',
  `actual_delivery_date` date DEFAULT NULL COMMENT '实际交货日期',
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'draft' COMMENT '订单状态（draft草稿、confirmed已确认、shipped已发货、received已收货、invoiced已对账、cancelled已取消）',
  `total_amount` decimal(12,2) DEFAULT '0.00' COMMENT '订单总金额（元）',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '订单备注',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录最后更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_supplier_id` (`supplier_id`),
  KEY `idx_pond_id` (`pond_id`),
  KEY `idx_status` (`status`),
  KEY `idx_order_date` (`order_date`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_supplier_status` (`supplier_id`,`status`),
  CONSTRAINT `fk_order_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_order_pond` FOREIGN KEY (`pond_id`) REFERENCES `ponds` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_order_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='采购订单主表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_orders`
--

/*!40000 ALTER TABLE `purchase_orders` DISABLE KEYS */;
INSERT INTO `purchase_orders` VALUES (1,1,32,6,'2026-04-18 09:19:10','2026-04-19',NULL,'received',2813.20,'采购订单 #1','2026-04-18 09:19:10','2026-04-18 09:19:10'),(2,2,30,6,'2026-04-18 09:19:10','2026-04-22',NULL,'confirmed',848.00,'采购订单 #2','2026-04-18 09:19:10','2026-04-18 09:19:10'),(3,1,32,6,'2026-04-18 09:19:10','2026-04-20',NULL,'draft',975.20,'采购订单 #3','2026-04-18 09:19:10','2026-04-18 09:19:10'),(4,3,32,6,'2026-04-18 09:19:10','2026-04-23',NULL,'received',1383.00,'采购订单 #4','2026-04-18 09:19:10','2026-04-18 09:19:10'),(5,1,31,6,'2026-04-18 09:19:10','2026-04-22',NULL,'shipped',311.80,'采购订单 #5','2026-04-18 09:19:10','2026-04-18 09:19:10'),(6,1,30,6,'2026-04-18 09:19:10','2026-04-19',NULL,'shipped',1733.90,'采购订单 #6','2026-04-18 09:19:10','2026-04-18 09:19:10'),(7,3,33,6,'2026-04-18 09:19:10','2026-04-22',NULL,'shipped',1094.40,'采购订单 #7','2026-04-18 09:19:10','2026-04-18 09:19:10'),(8,3,32,6,'2026-04-18 09:19:10','2026-04-19',NULL,'confirmed',2485.20,'采购订单 #8','2026-04-18 09:19:10','2026-04-18 09:19:10'),(9,2,31,6,'2026-04-18 09:19:10','2026-04-23',NULL,'confirmed',1958.40,'采购订单 #9','2026-04-18 09:19:10','2026-04-18 09:19:10'),(10,3,32,6,'2026-04-18 09:19:10','2026-04-22',NULL,'shipped',1715.40,'采购订单 #10','2026-04-18 09:19:10','2026-04-18 09:19:10');
/*!40000 ALTER TABLE `purchase_orders` ENABLE KEYS */;

--
-- Table structure for table `seedling_inventory`
--

DROP TABLE IF EXISTS `seedling_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seedling_inventory` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '库存记录唯一编号',
  `supplier_id` int NOT NULL COMMENT '供应商编号',
  `product_id` int NOT NULL COMMENT '产品编号',
  `quantity` int NOT NULL DEFAULT '0' COMMENT '当前库存数量（尾）',
  `last_updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '更新人（用户名）',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_supplier_product` (`supplier_id`,`product_id`),
  KEY `idx_supplier_id` (`supplier_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_supplier_product` (`supplier_id`,`product_id`),
  CONSTRAINT `fk_inventory_product` FOREIGN KEY (`product_id`) REFERENCES `seedling_products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_inventory_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鱼苗库存表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seedling_inventory`
--

/*!40000 ALTER TABLE `seedling_inventory` DISABLE KEYS */;
INSERT INTO `seedling_inventory` VALUES (1,1,1,2534,'2026-04-18 09:19:10','system'),(2,1,2,2884,'2026-04-18 09:19:10','system'),(3,2,3,4196,'2026-04-18 09:19:10','system'),(4,2,4,2183,'2026-04-18 09:19:10','system'),(5,3,5,1602,'2026-04-18 09:19:10','system'),(6,3,6,4436,'2026-04-18 09:19:10','system');
/*!40000 ALTER TABLE `seedling_inventory` ENABLE KEYS */;

--
-- Table structure for table `seedling_products`
--

DROP TABLE IF EXISTS `seedling_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seedling_products` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '鱼苗产品唯一编号',
  `supplier_id` int NOT NULL COMMENT '所属供应商编号',
  `product_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '产品名称（如"一龄草鱼苗"）',
  `species` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '鱼苗种类（草鱼、鲈鱼、鲤鱼等）',
  `grade` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '鱼苗等级（一龄、二龄、健康、优质等）',
  `unit_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '单价（元/尾）',
  `cost_price` decimal(10,2) DEFAULT NULL COMMENT '成本价（元/尾）',
  `growth_cycle_days` int DEFAULT NULL COMMENT '生长周期（天）',
  `survival_rate` float DEFAULT NULL COMMENT '存活率（%）',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '产品图片URL',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '产品详细描述',
  `is_active` tinyint(1) DEFAULT '1' COMMENT '产品是否上架（1上架、0下架）',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录最后更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_supplier_id` (`supplier_id`),
  KEY `idx_species` (`species`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_seedling_products_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='鱼苗产品库表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seedling_products`
--

/*!40000 ALTER TABLE `seedling_products` DISABLE KEYS */;
INSERT INTO `seedling_products` VALUES (1,1,'一龄草鱼苗','草鱼','一龄优质',0.80,0.40,180,95,NULL,'健壮活力强，存活率高',1,'2026-04-18 09:19:10','2026-04-18 09:19:10'),(2,1,'二龄草鱼苗','草鱼','二龄',1.50,0.70,120,98,NULL,'大规格草鱼苗',1,'2026-04-18 09:19:10','2026-04-18 09:19:10'),(3,2,'鲈鱼苗（寸苗）','鲈鱼','寸苗',2.00,1.00,150,92,NULL,'优质鲈鱼种苗',1,'2026-04-18 09:19:10','2026-04-18 09:19:10'),(4,2,'鲈鱼苗（尾苗）','鲈鱼','尾苗',1.20,0.60,180,90,NULL,'经济实惠的鲈鱼苗',1,'2026-04-18 09:19:10','2026-04-18 09:19:10'),(5,3,'鲤鱼苗','鲤鱼','一龄',0.60,0.30,200,93,NULL,'健壮的鲤鱼苗',1,'2026-04-18 09:19:10','2026-04-18 09:19:10'),(6,3,'鲶鱼苗','鲶鱼','寸苗',1.80,0.90,160,94,NULL,'生长快的鲶鱼苗',1,'2026-04-18 09:19:10','2026-04-18 09:19:10');
/*!40000 ALTER TABLE `seedling_products` ENABLE KEYS */;

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
  `food_value` float DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=784 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='传感器水质监测数据表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sensor_data`
--

/*!40000 ALTER TABLE `sensor_data` DISABLE KEYS */;
INSERT INTO `sensor_data` VALUES (759,29,25.26,7.42,56.43,7.88,13.42,2.82,1.17,'2026-04-17 09:19:10'),(760,29,26.73,7.51,78.09,7.14,13.36,3.38,1.05,'2026-04-17 15:19:10'),(761,29,24.95,8.12,84.14,8.85,12.32,2.94,1.13,'2026-04-17 21:19:10'),(762,29,24.55,8.28,39.43,8.67,14.24,2.42,1.03,'2026-04-18 03:19:10'),(763,29,25.45,7.3,75.75,8.77,15.02,2.96,0.9,'2026-04-18 09:19:10'),(764,30,25.46,7.74,73.46,8.13,13.94,2.8,1.46,'2026-04-17 09:19:10'),(765,30,25.29,7.98,76.04,7.95,16.82,3.26,1.68,'2026-04-17 15:19:10'),(766,30,25.15,7.74,97.84,7.01,15.64,3.77,1.37,'2026-04-17 21:19:10'),(767,30,22.24,7.38,39.07,8.3,13.4,4,1.67,'2026-04-18 03:19:10'),(768,30,24.99,7.77,57.81,8.31,16.67,3.13,1.19,'2026-04-18 09:19:10'),(769,31,23.62,7.57,59.84,8.84,13.08,2.69,1.4,'2026-04-17 09:19:10'),(770,31,26.52,7.1,86.79,8.35,12.66,3.66,1.11,'2026-04-17 15:19:10'),(771,31,23.33,7.76,92.41,8.27,15.12,2.08,0.96,'2026-04-17 21:19:10'),(772,31,22.49,8.23,54.69,8.16,14.77,2.42,1.36,'2026-04-18 03:19:10'),(773,31,23.37,7.06,52.2,8.05,12.76,3.52,1.7,'2026-04-18 09:19:10'),(774,32,22.6,7.06,59.94,7.16,14.45,3.35,1.63,'2026-04-17 09:19:10'),(775,32,24.79,7.97,79.08,8.59,16.65,2.47,1.18,'2026-04-17 15:19:10'),(776,32,25.02,7.1,78.61,8.57,12.17,2.35,1.55,'2026-04-17 21:19:10'),(777,32,26.93,8.03,58.81,8.2,15.96,3.14,1.1,'2026-04-18 03:19:10'),(778,32,24.1,7.13,64.22,7.03,16.05,3.98,1.43,'2026-04-18 09:19:10'),(779,33,26.14,7.76,57.68,7.51,15.16,2.85,1.06,'2026-04-17 09:19:10'),(780,33,26.2,7.64,81.71,8.07,12.46,3.44,1.04,'2026-04-17 15:19:10'),(781,33,24.58,8,98.54,7.56,12.77,2.24,1.6,'2026-04-17 21:19:10'),(782,33,26.15,8.25,50.54,7.24,12.14,3.77,1.13,'2026-04-18 03:19:10'),(783,33,26.23,7.34,63.1,8.56,14.87,2.3,1.15,'2026-04-18 09:19:10');
/*!40000 ALTER TABLE `sensor_data` ENABLE KEYS */;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suppliers` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '供应商唯一编号',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '供应商企业名称',
  `contact_person` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '主要联系人姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系电话',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '联系邮箱',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '企业地址',
  `registration_date` date DEFAULT NULL COMMENT '注册时间',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active' COMMENT '供应商状态（active激活、inactive停用、suspended暂停）',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '备注信息',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录最后更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_name` (`name`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='供应商企业信息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES (1,'清源水产养殖基地','王经理','13800138001','supplier1@fishery.com','浙江省杭州市西湖区','2026-04-18','active','专业草鱼苗供应商','2026-04-18 09:19:10','2026-04-18 09:19:10'),(2,'锦鲤养殖中心','李总','13800138002','supplier2@fishery.com','江苏省无锡市滨湖区','2026-04-18','active','优质鲈鱼鱼苗供应','2026-04-18 09:19:10','2026-04-18 09:19:10'),(3,'生态鱼苗繁育场','陈女士','13800138003','supplier3@fishery.com','江西省南昌市青云谱区','2026-04-18','active','鲤鱼、鲶鱼苗种','2026-04-18 09:19:10','2026-04-18 09:19:10');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;

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
  `supplier_id` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1' COMMENT '用户账号是否激活',
  `last_login` datetime DEFAULT NULL COMMENT '上次登录时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '账号创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '账号最后更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_role` (`role`),
  KEY `idx_is_active` (`is_active`),
  KEY `fk_user_supplier` (`supplier_id`),
  CONSTRAINT `fk_user_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户管理表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (6,'admin',NULL,'admin123',NULL,'admin',NULL,1,'2026-04-18 15:28:37','2026-04-18 09:19:10','2026-04-18 15:28:37'),(7,'operator',NULL,'operator123',NULL,'operator',NULL,1,NULL,'2026-04-18 09:19:10','2026-04-18 09:19:10'),(8,'supplier1','user1@supplier1.com','supplier123','张供应商','supplier',1,1,'2026-04-18 14:51:51','2026-04-18 09:19:10','2026-04-18 14:51:51'),(9,'supplier2','user2@supplier2.com','supplier123','李供应商','supplier',2,1,NULL,'2026-04-18 09:19:10','2026-04-18 09:19:10');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;

--
-- Table structure for table `water_quality_thresholds`
--

DROP TABLE IF EXISTS `water_quality_thresholds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `water_quality_thresholds` (
  `id` int NOT NULL AUTO_INCREMENT,
  `parameter_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `parameter_key` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `min_value` float DEFAULT NULL,
  `max_value` float DEFAULT NULL,
  `warning_level` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unit` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `parameter_name` (`parameter_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `water_quality_thresholds`
--

/*!40000 ALTER TABLE `water_quality_thresholds` DISABLE KEYS */;
/*!40000 ALTER TABLE `water_quality_thresholds` ENABLE KEYS */;

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

-- Dump completed on 2026-04-18 23:37:36
