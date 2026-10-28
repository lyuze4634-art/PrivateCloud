CREATE DATABASE IF NOT EXISTS private_cloud
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE private_cloud;

CREATE TABLE IF NOT EXISTS folders (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    parent_id BIGINT UNSIGNED NULL,
    name VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL,
    PRIMARY KEY (id),
    KEY idx_folders_parent_id (parent_id),
    UNIQUE KEY uq_folders_parent_name (parent_id, name),
    CONSTRAINT fk_folders_parent
        FOREIGN KEY (parent_id) REFERENCES folders (id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS files (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    folder_id BIGINT UNSIGNED NULL,
    original_name TEXT NOT NULL,
    storage_name CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    file_size BIGINT UNSIGNED NOT NULL,
    uploaded_at DATETIME NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_files_storage_name (storage_name),
    KEY idx_files_folder_id (folder_id),
    KEY idx_files_uploaded_at (uploaded_at),
    CONSTRAINT fk_files_folder
        FOREIGN KEY (folder_id) REFERENCES folders (id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
