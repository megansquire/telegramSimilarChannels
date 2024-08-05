SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

CREATE TABLE `ChannelSuggestions` (
  `suggestion_id` int NOT NULL,
  `entity_id` int DEFAULT NULL,
  `suggested_entity_id` int DEFAULT NULL,
  `recorded_at` datetime DEFAULT NULL,
  `collection_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Collections` (
  `collection_id` int NOT NULL,
  `start_date` date DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Entities` (
  `entity_id` int NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `type` enum('channel','group','supergroup') DEFAULT NULL,
  `member_count` int DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `description` text,
  `photo_id` varchar(255) DEFAULT NULL,
  `creation_date` datetime DEFAULT NULL,
  `last_updated` datetime DEFAULT NULL,
  `collection_id` int DEFAULT NULL,
  `indegree` int DEFAULT NULL,
  `outdegree` int DEFAULT NULL,
  `degree` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `EntityHistory` (
  `history_id` int NOT NULL,
  `entity_id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `type` enum('channel','group','supergroup') DEFAULT NULL,
  `member_count` int DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `description` text,
  `photo_id` varchar(255) DEFAULT NULL,
  `creation_date` datetime DEFAULT NULL,
  `last_updated` datetime DEFAULT NULL,
  `collection_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `EntityLanguage` (
  `entity_id` int NOT NULL,
  `nameStatus` enum('text','detectable','undetectable') DEFAULT NULL COMMENT 'Regular text, detectable unicode, or undetectable unicode',
  `descStatus` enum('text','detectable','undetectable') DEFAULT NULL COMMENT 'Regular text, detectable unicode, or undetectable unicode',
  `nameLangCode` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `nameLang` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `descLangCode` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `descLang` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `last_updated` datetime DEFAULT NULL,
  `collection_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `ScrapingJobs` (
  `job_id` int NOT NULL,
  `entity_id` int DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `status` enum('pending','in_progress','completed','failed') DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


ALTER TABLE `ChannelSuggestions`
  ADD PRIMARY KEY (`suggestion_id`),
  ADD KEY `entity_id` (`entity_id`),
  ADD KEY `suggested_entity_id` (`suggested_entity_id`),
  ADD KEY `collection_id` (`collection_id`);

ALTER TABLE `Collections`
  ADD PRIMARY KEY (`collection_id`);

ALTER TABLE `Entities`
  ADD PRIMARY KEY (`entity_id`),
  ADD KEY `collection_id` (`collection_id`);

ALTER TABLE `EntityHistory`
  ADD PRIMARY KEY (`history_id`),
  ADD UNIQUE KEY `unique_entity_collection` (`collection_id`,`entity_id`),
  ADD KEY `entity_id` (`entity_id`);

ALTER TABLE `EntityLanguage`
  ADD PRIMARY KEY (`entity_id`),
  ADD KEY `collection_id` (`collection_id`);

ALTER TABLE `ScrapingJobs`
  ADD PRIMARY KEY (`job_id`);


ALTER TABLE `ChannelSuggestions`
  MODIFY `suggestion_id` int NOT NULL AUTO_INCREMENT;

ALTER TABLE `EntityHistory`
  MODIFY `history_id` int NOT NULL AUTO_INCREMENT;

ALTER TABLE `ScrapingJobs`
  MODIFY `job_id` int NOT NULL AUTO_INCREMENT;


ALTER TABLE `ChannelSuggestions`
  ADD CONSTRAINT `channelsuggestions_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `Entities` (`entity_id`),
  ADD CONSTRAINT `channelsuggestions_ibfk_2` FOREIGN KEY (`suggested_entity_id`) REFERENCES `Entities` (`entity_id`),
  ADD CONSTRAINT `channelsuggestions_ibfk_3` FOREIGN KEY (`collection_id`) REFERENCES `Collections` (`collection_id`);

ALTER TABLE `Entities`
  ADD CONSTRAINT `entities_ibfk_1` FOREIGN KEY (`collection_id`) REFERENCES `Collections` (`collection_id`);

ALTER TABLE `EntityHistory`
  ADD CONSTRAINT `entityhistory_ibfk_1` FOREIGN KEY (`entity_id`) REFERENCES `Entities` (`entity_id`),
  ADD CONSTRAINT `entityhistory_ibfk_2` FOREIGN KEY (`collection_id`) REFERENCES `Collections` (`collection_id`);

ALTER TABLE `EntityLanguage`
  ADD CONSTRAINT `fk_entity_id` FOREIGN KEY (`entity_id`) REFERENCES `Entities` (`entity_id`);
