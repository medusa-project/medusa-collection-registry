--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: access_system_collection_joins_touch_access_system(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION access_system_collection_joins_touch_access_system() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE access_systems
        SET updated_at = NEW.updated_at
        WHERE id = NEW.access_system_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE access_systems
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.access_system_id OR id = OLD.access_system_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE access_systems
        SET updated_at = localtimestamp
        WHERE id = OLD.access_system_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: access_system_collection_joins_touch_collection(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION access_system_collection_joins_touch_collection() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE collections
        SET updated_at = NEW.updated_at
        WHERE id = NEW.collection_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE collections
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.collection_id OR id = OLD.collection_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE collections
        SET updated_at = localtimestamp
        WHERE id = OLD.collection_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: amazon_backups_touch_cfs_directory(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION amazon_backups_touch_cfs_directory() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE cfs_directories
        SET updated_at = NEW.updated_at
        WHERE id = NEW.cfs_directory_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE cfs_directories
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.cfs_directory_id OR id = OLD.cfs_directory_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE cfs_directories
        SET updated_at = localtimestamp
        WHERE id = OLD.cfs_directory_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: amazon_backups_touch_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION amazon_backups_touch_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE users
        SET updated_at = NEW.updated_at
        WHERE id = NEW.user_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE users
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.user_id OR id = OLD.user_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE users
        SET updated_at = localtimestamp
        WHERE id = OLD.user_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: assessments_touch_storage_medium(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION assessments_touch_storage_medium() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE storage_media
        SET updated_at = NEW.updated_at
        WHERE id = NEW.storage_medium_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE storage_media
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.storage_medium_id OR id = OLD.storage_medium_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE storage_media
        SET updated_at = localtimestamp
        WHERE id = OLD.storage_medium_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: cfs_dir_update_bit_level_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cfs_dir_update_bit_level_file_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF ((TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND NEW.parent_type = 'FileGroup')  THEN
      UPDATE file_groups
      SET total_files = NEW.tree_count,
          total_file_size = NEW.tree_size / 1073741824
      WHERE id = NEW.parent_id;
    ELSIF (TG_OP = 'DELETE' AND OLD.parent_type = 'FileGroup') THEN
      UPDATE file_groups
      SET total_files = 0,
          total_file_size = 0
      WHERE id = OLD.parent_id;
    END IF;
    RETURN NULL;
  END;
$$;


--
-- Name: cfs_dir_update_cfs_dir(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cfs_dir_update_cfs_dir() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF (TG_OP = 'INSERT' AND NEW.parent_type = 'CfsDirectory') THEN
      UPDATE cfs_directories
      SET tree_count = tree_count + NEW.tree_count,
          tree_size = tree_size + NEW.tree_size
      WHERE id = NEW.parent_id;
    ELSIF (TG_OP = 'UPDATE' AND NEW.parent_type = 'CfsDirectory') THEN
      IF ((NEW.tree_size != OLD.tree_size) OR NEW.tree_count != OLD.tree_count) THEN
        UPDATE cfs_directories
        SET tree_size = tree_size + (NEW.tree_size - OLD.tree_size),
            tree_count = tree_count + (NEW.tree_count - OLD.tree_count)
        WHERE id = NEW.parent_id;
      END IF;
    ELSIF (TG_OP = 'DELETE' AND OLD.parent_type = 'CfsDirectory') THEN
      UPDATE cfs_directories
      SET tree_count = tree_count - OLD.tree_count,
          tree_size = tree_size - OLD.tree_size
      WHERE id = OLD.parent_id;
    END IF;
    RETURN NULL;
  END;
$$;


--
-- Name: cfs_file_update_cfs_directory_and_extension_and_content_type(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cfs_file_update_cfs_directory_and_extension_and_content_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF (TG_OP = 'INSERT') THEN
          UPDATE cfs_directories
    SET tree_count = tree_count + 1,
        tree_size = tree_size + COALESCE(NEW.size, 0)
    WHERE id = NEW.cfs_directory_id
;
          UPDATE content_types
    SET cfs_file_count = cfs_file_count + 1,
        cfs_file_size = cfs_file_size + COALESCE(NEW.size, 0)
    WHERE id = NEW.content_type_id
;
          UPDATE file_extensions
    SET cfs_file_count = cfs_file_count + 1,
        cfs_file_size = cfs_file_size + COALESCE(NEW.size, 0)
    WHERE id = NEW.file_extension_id
;
    ELSIF (TG_OP = 'UPDATE') THEN
      IF (NEW.cfs_directory_id = OLD.cfs_directory_id) THEN
        IF (COALESCE(NEW.size,0) != COALESCE(OLD.size,0)) THEN
  UPDATE cfs_directories
  SET tree_size = tree_size + (COALESCE(NEW.size,0) - COALESCE(OLD.size,0))
  WHERE id = NEW.cfs_directory_id;
END IF
;
      ELSE
            UPDATE cfs_directories
    SET tree_count = tree_count + 1,
        tree_size = tree_size + COALESCE(NEW.size, 0)
    WHERE id = NEW.cfs_directory_id
;
            UPDATE cfs_directories
    SET tree_count = tree_count - 1,
        tree_size = tree_size - COALESCE(OLD.size, 0)
    WHERE id = OLD.cfs_directory_id
;
      END IF;
      IF (NEW.content_type_id = OLD.content_type_id) THEN
        IF (COALESCE(NEW.size,0) != COALESCE(OLD.size,0)) THEN
  UPDATE content_types
  SET cfs_file_size = cfs_file_size + (COALESCE(NEW.size,0) - COALESCE(OLD.size,0))
  WHERE id = NEW.content_type_id;
END IF
;
      ELSE
            UPDATE content_types
    SET cfs_file_count = cfs_file_count + 1,
        cfs_file_size = cfs_file_size + COALESCE(NEW.size, 0)
    WHERE id = NEW.content_type_id
;
            UPDATE content_types
    SET cfs_file_count = cfs_file_count - 1,
        cfs_file_size = cfs_file_size - COALESCE(OLD.size, 0)
    WHERE id = OLD.content_type_id
;
      END IF;
      IF (NEW.file_extension_id = OLD.file_extension_id) THEN
        IF (COALESCE(NEW.size,0) != COALESCE(OLD.size,0)) THEN
  UPDATE file_extensions
  SET cfs_file_size = cfs_file_size + (COALESCE(NEW.size,0) - COALESCE(OLD.size,0))
  WHERE id = NEW.file_extension_id;
END IF
;
      ELSE
            UPDATE file_extensions
    SET cfs_file_count = cfs_file_count + 1,
        cfs_file_size = cfs_file_size + COALESCE(NEW.size, 0)
    WHERE id = NEW.file_extension_id
;
            UPDATE file_extensions
    SET cfs_file_count = cfs_file_count - 1,
        cfs_file_size = cfs_file_size - COALESCE(OLD.size, 0)
    WHERE id = OLD.file_extension_id
;
      END IF;
    ELSIF (TG_OP = 'DELETE') THEN
          UPDATE cfs_directories
    SET tree_count = tree_count - 1,
        tree_size = tree_size - COALESCE(OLD.size, 0)
    WHERE id = OLD.cfs_directory_id
;
          UPDATE content_types
    SET cfs_file_count = cfs_file_count - 1,
        cfs_file_size = cfs_file_size - COALESCE(OLD.size, 0)
    WHERE id = OLD.content_type_id
;
          UPDATE file_extensions
    SET cfs_file_count = cfs_file_count - 1,
        cfs_file_size = cfs_file_size - COALESCE(OLD.size, 0)
    WHERE id = OLD.file_extension_id
;
    END IF;
    RETURN NULL;
  END;
$$;


--
-- Name: cfs_files_touch_cfs_directory(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cfs_files_touch_cfs_directory() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE cfs_directories
        SET updated_at = NEW.updated_at
        WHERE id = NEW.cfs_directory_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE cfs_directories
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.cfs_directory_id OR id = OLD.cfs_directory_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE cfs_directories
        SET updated_at = localtimestamp
        WHERE id = OLD.cfs_directory_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: cfs_files_touch_content_type(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cfs_files_touch_content_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE content_types
        SET updated_at = NEW.updated_at
        WHERE id = NEW.content_type_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE content_types
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.content_type_id OR id = OLD.content_type_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE content_types
        SET updated_at = localtimestamp
        WHERE id = OLD.content_type_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: cfs_files_touch_file_extension(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cfs_files_touch_file_extension() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE file_extensions
        SET updated_at = NEW.updated_at
        WHERE id = NEW.file_extension_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE file_extensions
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.file_extension_id OR id = OLD.file_extension_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE file_extensions
        SET updated_at = localtimestamp
        WHERE id = OLD.file_extension_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: collections_touch_preservation_priority(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION collections_touch_preservation_priority() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE preservation_priorities
        SET updated_at = NEW.updated_at
        WHERE id = NEW.preservation_priority_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE preservation_priorities
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.preservation_priority_id OR id = OLD.preservation_priority_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE preservation_priorities
        SET updated_at = localtimestamp
        WHERE id = OLD.preservation_priority_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: collections_touch_repository(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION collections_touch_repository() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE repositories
        SET updated_at = NEW.updated_at
        WHERE id = NEW.repository_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE repositories
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.repository_id OR id = OLD.repository_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE repositories
        SET updated_at = localtimestamp
        WHERE id = OLD.repository_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: file_groups_touch_collection(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION file_groups_touch_collection() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE collections
        SET updated_at = NEW.updated_at
        WHERE id = NEW.collection_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE collections
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.collection_id OR id = OLD.collection_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE collections
        SET updated_at = localtimestamp
        WHERE id = OLD.collection_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: file_groups_touch_package_profile(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION file_groups_touch_package_profile() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE package_profiles
        SET updated_at = NEW.updated_at
        WHERE id = NEW.package_profile_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE package_profiles
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.package_profile_id OR id = OLD.package_profile_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE package_profiles
        SET updated_at = localtimestamp
        WHERE id = OLD.package_profile_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: file_groups_touch_producer(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION file_groups_touch_producer() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE producers
        SET updated_at = NEW.updated_at
        WHERE id = NEW.producer_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE producers
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.producer_id OR id = OLD.producer_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE producers
        SET updated_at = localtimestamp
        WHERE id = OLD.producer_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: job_cfs_directory_exports_touch_cfs_directory(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION job_cfs_directory_exports_touch_cfs_directory() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE cfs_directories
        SET updated_at = NEW.updated_at
        WHERE id = NEW.cfs_directory_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE cfs_directories
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.cfs_directory_id OR id = OLD.cfs_directory_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE cfs_directories
        SET updated_at = localtimestamp
        WHERE id = OLD.cfs_directory_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: job_cfs_directory_exports_touch_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION job_cfs_directory_exports_touch_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE users
        SET updated_at = NEW.updated_at
        WHERE id = NEW.user_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE users
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.user_id OR id = OLD.user_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE users
        SET updated_at = localtimestamp
        WHERE id = OLD.user_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: job_cfs_initial_file_group_assessments_touch_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION job_cfs_initial_file_group_assessments_touch_file_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE id = NEW.file_group_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.file_group_id OR id = OLD.file_group_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE file_groups
        SET updated_at = localtimestamp
        WHERE id = OLD.file_group_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: job_fits_directories_touch_cfs_directory(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION job_fits_directories_touch_cfs_directory() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE cfs_directories
        SET updated_at = NEW.updated_at
        WHERE id = NEW.cfs_directory_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE cfs_directories
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.cfs_directory_id OR id = OLD.cfs_directory_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE cfs_directories
        SET updated_at = localtimestamp
        WHERE id = OLD.cfs_directory_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: job_fits_directories_touch_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION job_fits_directories_touch_file_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE id = NEW.file_group_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.file_group_id OR id = OLD.file_group_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE file_groups
        SET updated_at = localtimestamp
        WHERE id = OLD.file_group_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: job_fits_directory_trees_touch_cfs_directory(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION job_fits_directory_trees_touch_cfs_directory() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE cfs_directories
        SET updated_at = NEW.updated_at
        WHERE id = NEW.cfs_directory_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE cfs_directories
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.cfs_directory_id OR id = OLD.cfs_directory_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE cfs_directories
        SET updated_at = localtimestamp
        WHERE id = OLD.cfs_directory_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: job_fits_directory_trees_touch_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION job_fits_directory_trees_touch_file_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE id = NEW.file_group_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.file_group_id OR id = OLD.file_group_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE file_groups
        SET updated_at = localtimestamp
        WHERE id = OLD.file_group_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: job_ingest_staging_deletes_touch_external_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION job_ingest_staging_deletes_touch_external_file_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE id = NEW.external_file_group_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.external_file_group_id OR id = OLD.external_file_group_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE file_groups
        SET updated_at = localtimestamp
        WHERE id = OLD.external_file_group_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: job_ingest_staging_deletes_touch_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION job_ingest_staging_deletes_touch_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE users
        SET updated_at = NEW.updated_at
        WHERE id = NEW.user_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE users
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.user_id OR id = OLD.user_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE users
        SET updated_at = localtimestamp
        WHERE id = OLD.user_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: job_virus_scans_touch_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION job_virus_scans_touch_file_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE id = NEW.file_group_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.file_group_id OR id = OLD.file_group_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE file_groups
        SET updated_at = localtimestamp
        WHERE id = OLD.file_group_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: projects_touch_collection(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION projects_touch_collection() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE collections
        SET updated_at = NEW.updated_at
        WHERE id = NEW.collection_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE collections
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.collection_id OR id = OLD.collection_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE collections
        SET updated_at = localtimestamp
        WHERE id = OLD.collection_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: related_file_group_joins_touch_source_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION related_file_group_joins_touch_source_file_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE id = NEW.source_file_group_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.source_file_group_id OR id = OLD.source_file_group_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE file_groups
        SET updated_at = localtimestamp
        WHERE id = OLD.source_file_group_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: related_file_group_joins_touch_target_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION related_file_group_joins_touch_target_file_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE id = NEW.target_file_group_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.target_file_group_id OR id = OLD.target_file_group_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE file_groups
        SET updated_at = localtimestamp
        WHERE id = OLD.target_file_group_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: repositories_touch_institution(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION repositories_touch_institution() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE institutions
        SET updated_at = NEW.updated_at
        WHERE id = NEW.institution_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE institutions
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.institution_id OR id = OLD.institution_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE institutions
        SET updated_at = localtimestamp
        WHERE id = OLD.institution_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: resource_typeable_resource_type_joins_touch_resource_type(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION resource_typeable_resource_type_joins_touch_resource_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE resource_types
        SET updated_at = NEW.updated_at
        WHERE id = NEW.resource_type_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE resource_types
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.resource_type_id OR id = OLD.resource_type_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE resource_types
        SET updated_at = localtimestamp
        WHERE id = OLD.resource_type_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: virus_scans_touch_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION virus_scans_touch_file_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE id = NEW.file_group_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.file_group_id OR id = OLD.file_group_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE file_groups
        SET updated_at = localtimestamp
        WHERE id = OLD.file_group_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: workflow_accrual_comments_touch_workflow_accrual_job(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION workflow_accrual_comments_touch_workflow_accrual_job() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE workflow_accrual_jobs
        SET updated_at = NEW.updated_at
        WHERE id = NEW.workflow_accrual_job_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE workflow_accrual_jobs
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.workflow_accrual_job_id OR id = OLD.workflow_accrual_job_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE workflow_accrual_jobs
        SET updated_at = localtimestamp
        WHERE id = OLD.workflow_accrual_job_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: workflow_accrual_conflicts_touch_workflow_accrual_job(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION workflow_accrual_conflicts_touch_workflow_accrual_job() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE workflow_accrual_jobs
        SET updated_at = NEW.updated_at
        WHERE id = NEW.workflow_accrual_job_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE workflow_accrual_jobs
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.workflow_accrual_job_id OR id = OLD.workflow_accrual_job_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE workflow_accrual_jobs
        SET updated_at = localtimestamp
        WHERE id = OLD.workflow_accrual_job_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: workflow_accrual_directories_touch_workflow_accrual_job(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION workflow_accrual_directories_touch_workflow_accrual_job() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE workflow_accrual_jobs
        SET updated_at = NEW.updated_at
        WHERE id = NEW.workflow_accrual_job_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE workflow_accrual_jobs
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.workflow_accrual_job_id OR id = OLD.workflow_accrual_job_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE workflow_accrual_jobs
        SET updated_at = localtimestamp
        WHERE id = OLD.workflow_accrual_job_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: workflow_accrual_files_touch_workflow_accrual_job(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION workflow_accrual_files_touch_workflow_accrual_job() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE workflow_accrual_jobs
        SET updated_at = NEW.updated_at
        WHERE id = NEW.workflow_accrual_job_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE workflow_accrual_jobs
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.workflow_accrual_job_id OR id = OLD.workflow_accrual_job_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE workflow_accrual_jobs
        SET updated_at = localtimestamp
        WHERE id = OLD.workflow_accrual_job_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: workflow_accrual_jobs_touch_amazon_backup(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION workflow_accrual_jobs_touch_amazon_backup() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE amazon_backups
        SET updated_at = NEW.updated_at
        WHERE id = NEW.amazon_backup_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE amazon_backups
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.amazon_backup_id OR id = OLD.amazon_backup_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE amazon_backups
        SET updated_at = localtimestamp
        WHERE id = OLD.amazon_backup_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: workflow_accrual_jobs_touch_cfs_directory(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION workflow_accrual_jobs_touch_cfs_directory() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE cfs_directories
        SET updated_at = NEW.updated_at
        WHERE id = NEW.cfs_directory_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE cfs_directories
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.cfs_directory_id OR id = OLD.cfs_directory_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE cfs_directories
        SET updated_at = localtimestamp
        WHERE id = OLD.cfs_directory_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: workflow_accrual_jobs_touch_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION workflow_accrual_jobs_touch_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE users
        SET updated_at = NEW.updated_at
        WHERE id = NEW.user_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE users
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.user_id OR id = OLD.user_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE users
        SET updated_at = localtimestamp
        WHERE id = OLD.user_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: workflow_ingests_touch_amazon_backup(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION workflow_ingests_touch_amazon_backup() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE amazon_backups
        SET updated_at = NEW.updated_at
        WHERE id = NEW.amazon_backup_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE amazon_backups
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.amazon_backup_id OR id = OLD.amazon_backup_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE amazon_backups
        SET updated_at = localtimestamp
        WHERE id = OLD.amazon_backup_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: workflow_ingests_touch_bit_level_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION workflow_ingests_touch_bit_level_file_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE id = NEW.bit_level_file_group_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.bit_level_file_group_id OR id = OLD.bit_level_file_group_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE file_groups
        SET updated_at = localtimestamp
        WHERE id = OLD.bit_level_file_group_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: workflow_ingests_touch_external_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION workflow_ingests_touch_external_file_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE id = NEW.external_file_group_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE file_groups
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.external_file_group_id OR id = OLD.external_file_group_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE file_groups
        SET updated_at = localtimestamp
        WHERE id = OLD.external_file_group_id;
      END IF;
      RETURN NULL;
    END;
$$;


--
-- Name: workflow_ingests_touch_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION workflow_ingests_touch_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
      IF (TG_OP = 'INSERT') THEN
        UPDATE users
        SET updated_at = NEW.updated_at
        WHERE id = NEW.user_id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE users
        SET updated_at = NEW.updated_at
        WHERE (id = NEW.user_id OR id = OLD.user_id);
      ELSIF (TG_OP = 'DELETE') THEN
        UPDATE users
        SET updated_at = localtimestamp
        WHERE id = OLD.user_id;
      END IF;
      RETURN NULL;
    END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: access_system_collection_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE access_system_collection_joins (
    id integer NOT NULL,
    access_system_id integer,
    collection_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: access_system_collection_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE access_system_collection_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_system_collection_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE access_system_collection_joins_id_seq OWNED BY access_system_collection_joins.id;


--
-- Name: access_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE access_systems (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    service_owner character varying(255),
    application_manager character varying(255)
);


--
-- Name: access_systems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE access_systems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_systems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE access_systems_id_seq OWNED BY access_systems.id;


--
-- Name: amazon_backups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE amazon_backups (
    id integer NOT NULL,
    cfs_directory_id integer,
    part_count integer,
    date date,
    archive_ids text,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: amazon_backups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE amazon_backups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: amazon_backups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE amazon_backups_id_seq OWNED BY amazon_backups.id;


--
-- Name: amqp_accrual_delete_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE amqp_accrual_delete_jobs (
    id integer NOT NULL,
    cfs_file_uuid character varying NOT NULL,
    client character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: amqp_accrual_delete_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE amqp_accrual_delete_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: amqp_accrual_delete_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE amqp_accrual_delete_jobs_id_seq OWNED BY amqp_accrual_delete_jobs.id;


--
-- Name: amqp_accrual_ingest_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE amqp_accrual_ingest_jobs (
    id integer NOT NULL,
    client character varying NOT NULL,
    staging_path character varying NOT NULL,
    uuid character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: amqp_accrual_ingest_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE amqp_accrual_ingest_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: amqp_accrual_ingest_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE amqp_accrual_ingest_jobs_id_seq OWNED BY amqp_accrual_ingest_jobs.id;


--
-- Name: archived_accrual_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE archived_accrual_jobs (
    id integer NOT NULL,
    report text,
    file_group_id integer,
    amazon_backup_id integer,
    user_id integer NOT NULL,
    workflow_accrual_job_id integer NOT NULL,
    state text NOT NULL,
    staging_path text NOT NULL,
    cfs_directory_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: archived_accrual_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE archived_accrual_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: archived_accrual_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE archived_accrual_jobs_id_seq OWNED BY archived_accrual_jobs.id;


--
-- Name: assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE assessments (
    id integer NOT NULL,
    date date,
    preservation_risks text,
    notes text,
    assessable_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    author_id integer,
    notes_html text,
    preservation_risks_html text,
    assessable_type character varying(255),
    name character varying(255),
    assessment_type character varying(255),
    preservation_risk_level character varying(255),
    naming_conventions text,
    naming_conventions_html text,
    storage_medium_id integer,
    directory_structure text,
    directory_structure_html text,
    last_access_date date,
    file_format character varying(255),
    total_file_size numeric,
    total_files integer
);


--
-- Name: assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assessments_id_seq OWNED BY assessments.id;


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE attachments (
    id integer NOT NULL,
    attachable_id integer,
    attachable_type character varying(255),
    attachment_file_name character varying(255),
    attachment_content_type character varying(255),
    attachment_file_size integer,
    author_id integer,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: book_tracker_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE book_tracker_items (
    id integer NOT NULL,
    bib_id integer,
    oclc_number character varying(255),
    obj_id character varying(255),
    title character varying(255),
    author character varying(255),
    volume character varying(255),
    date character varying(255),
    exists_in_hathitrust boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ia_identifier character varying(255),
    exists_in_internet_archive boolean DEFAULT false,
    raw_marcxml text,
    exists_in_google boolean DEFAULT false,
    source_path text,
    hathitrust_rights character varying
);


--
-- Name: book_tracker_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE book_tracker_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: book_tracker_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE book_tracker_items_id_seq OWNED BY book_tracker_items.id;


--
-- Name: book_tracker_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE book_tracker_tasks (
    id integer NOT NULL,
    name character varying(255),
    service numeric(1,0),
    status numeric(1,0),
    percent_complete double precision DEFAULT 0.0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    completed_at timestamp without time zone
);


--
-- Name: book_tracker_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE book_tracker_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: book_tracker_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE book_tracker_tasks_id_seq OWNED BY book_tracker_tasks.id;


--
-- Name: cascaded_event_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cascaded_event_joins (
    id integer NOT NULL,
    cascaded_eventable_id integer,
    cascaded_eventable_type character varying,
    event_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cascaded_event_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cascaded_event_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cascaded_event_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cascaded_event_joins_id_seq OWNED BY cascaded_event_joins.id;


--
-- Name: cascaded_red_flag_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cascaded_red_flag_joins (
    id integer NOT NULL,
    cascaded_red_flaggable_id integer,
    cascaded_red_flaggable_type character varying,
    red_flag_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cascaded_red_flag_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cascaded_red_flag_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cascaded_red_flag_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cascaded_red_flag_joins_id_seq OWNED BY cascaded_red_flag_joins.id;


--
-- Name: cfs_directories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cfs_directories (
    id integer NOT NULL,
    path text,
    root_cfs_directory_id integer,
    tree_size numeric DEFAULT 0,
    tree_count integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    parent_id integer,
    parent_type character varying
);


--
-- Name: cfs_directories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cfs_directories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cfs_directories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cfs_directories_id_seq OWNED BY cfs_directories.id;


--
-- Name: cfs_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cfs_files (
    id integer NOT NULL,
    cfs_directory_id integer,
    name character varying(255),
    size numeric,
    mtime timestamp without time zone,
    md5_sum character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    content_type_id integer,
    file_extension_id integer,
    fixity_check_time timestamp without time zone,
    fixity_check_status character varying,
    fits_serialized boolean DEFAULT false NOT NULL
);


--
-- Name: cfs_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cfs_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cfs_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cfs_files_id_seq OWNED BY cfs_files.id;


--
-- Name: collection_virtual_repository_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE collection_virtual_repository_joins (
    id integer NOT NULL,
    collection_id integer,
    virtual_repository_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: collection_virtual_repository_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collection_virtual_repository_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_virtual_repository_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collection_virtual_repository_joins_id_seq OWNED BY collection_virtual_repository_joins.id;


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE collections (
    id integer NOT NULL,
    repository_id integer,
    title character varying(255),
    description text,
    access_url character varying(255),
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contact_id integer,
    preservation_priority_id integer,
    private_description text,
    notes_html text,
    description_html text,
    private_description_html text,
    external_id character varying(255),
    publish boolean DEFAULT false,
    representative_image character varying DEFAULT ''::character varying,
    representative_item character varying DEFAULT ''::character varying
);


--
-- Name: collections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collections_id_seq OWNED BY collections.id;


--
-- Name: content_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE content_types (
    id integer NOT NULL,
    name character varying(255) DEFAULT ''::character varying,
    cfs_file_count integer DEFAULT 0,
    cfs_file_size numeric DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: content_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_types_id_seq OWNED BY content_types.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: downloader_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE downloader_requests (
    id integer NOT NULL,
    email character varying,
    cfs_directory_id integer,
    downloader_id character varying,
    status character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: downloader_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE downloader_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloader_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE downloader_requests_id_seq OWNED BY downloader_requests.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE events (
    id integer NOT NULL,
    key character varying(255),
    note text,
    eventable_id integer,
    eventable_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    actor_email character varying(255),
    date date,
    cascadable boolean DEFAULT true
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: file_extensions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_extensions (
    id integer NOT NULL,
    extension character varying NOT NULL,
    cfs_file_size numeric DEFAULT 0,
    cfs_file_count integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: file_extensions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_extensions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_extensions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_extensions_id_seq OWNED BY file_extensions.id;


--
-- Name: file_format_normalization_paths; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_format_normalization_paths (
    id integer NOT NULL,
    file_format_id integer,
    name character varying,
    software character varying,
    software_version character varying,
    operating_system character varying,
    software_settings text,
    potential_for_loss text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    output_format_id integer,
    notes text
);


--
-- Name: file_format_normalization_paths_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_format_normalization_paths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_normalization_paths_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_format_normalization_paths_id_seq OWNED BY file_format_normalization_paths.id;


--
-- Name: file_format_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_format_notes (
    id integer NOT NULL,
    file_format_id integer,
    user_id integer,
    date date NOT NULL,
    note text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: file_format_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_format_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_format_notes_id_seq OWNED BY file_format_notes.id;


--
-- Name: file_format_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_format_profiles (
    id integer NOT NULL,
    name character varying NOT NULL,
    software character varying,
    software_version character varying,
    os_environment character varying,
    os_version character varying,
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    file_format_id integer
);


--
-- Name: file_format_profiles_content_types_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_format_profiles_content_types_joins (
    id integer NOT NULL,
    file_format_profile_id integer,
    content_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: file_format_profiles_content_types_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_format_profiles_content_types_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_profiles_content_types_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_format_profiles_content_types_joins_id_seq OWNED BY file_format_profiles_content_types_joins.id;


--
-- Name: file_format_profiles_file_extensions_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_format_profiles_file_extensions_joins (
    id integer NOT NULL,
    file_format_profile_id integer,
    file_extension_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: file_format_profiles_file_extensions_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_format_profiles_file_extensions_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_profiles_file_extensions_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_format_profiles_file_extensions_joins_id_seq OWNED BY file_format_profiles_file_extensions_joins.id;


--
-- Name: file_format_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_format_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_format_profiles_id_seq OWNED BY file_format_profiles.id;


--
-- Name: file_format_test_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_format_test_reasons (
    id integer NOT NULL,
    label character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: file_format_test_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_format_test_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_test_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_format_test_reasons_id_seq OWNED BY file_format_test_reasons.id;


--
-- Name: file_format_tests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_format_tests (
    id integer NOT NULL,
    cfs_file_id integer NOT NULL,
    tester_email character varying NOT NULL,
    date date NOT NULL,
    pass boolean DEFAULT true NOT NULL,
    notes text DEFAULT ''::text,
    file_format_profile_id integer NOT NULL
);


--
-- Name: file_format_tests_file_format_test_reasons_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_format_tests_file_format_test_reasons_joins (
    id integer NOT NULL,
    file_format_test_id integer,
    file_format_test_reason_id integer
);


--
-- Name: file_format_tests_file_format_test_reasons_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_format_tests_file_format_test_reasons_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_tests_file_format_test_reasons_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_format_tests_file_format_test_reasons_joins_id_seq OWNED BY file_format_tests_file_format_test_reasons_joins.id;


--
-- Name: file_format_tests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_format_tests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_tests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_format_tests_id_seq OWNED BY file_format_tests.id;


--
-- Name: file_formats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_formats (
    id integer NOT NULL,
    name character varying NOT NULL,
    policy_summary text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: file_formats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_formats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_formats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_formats_id_seq OWNED BY file_formats.id;


--
-- Name: file_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE file_groups (
    id integer NOT NULL,
    external_file_location character varying(255),
    file_format character varying(255),
    total_file_size numeric,
    total_files integer,
    collection_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    producer_id integer,
    description text,
    provenance_note text,
    title character varying(255),
    staged_file_location character varying(255),
    cfs_root character varying(255),
    type character varying(255),
    package_profile_id integer,
    external_id character varying(255),
    private_description text,
    access_url character varying(255),
    contact_id integer,
    acquisition_method character varying
);


--
-- Name: file_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE file_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE file_groups_id_seq OWNED BY file_groups.id;


--
-- Name: fits_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE fits_data (
    id integer NOT NULL,
    cfs_file_id integer NOT NULL,
    file_format character varying DEFAULT ''::character varying,
    file_format_version character varying DEFAULT ''::character varying,
    mime_type character varying DEFAULT ''::character varying,
    pronom_id character varying DEFAULT ''::character varying,
    file_size numeric,
    last_modified_date timestamp without time zone,
    creation_date timestamp without time zone,
    creating_application character varying DEFAULT ''::character varying,
    well_formed character varying DEFAULT ''::character varying,
    is_valid character varying DEFAULT ''::character varying,
    message character varying DEFAULT ''::character varying,
    audio_bit_depth integer,
    audio_byte_order character varying DEFAULT ''::character varying,
    audio_data_encoding character varying DEFAULT ''::character varying,
    audio_sample_rate integer,
    document_protection character varying DEFAULT ''::character varying,
    document_rights_management character varying DEFAULT ''::character varying,
    image_bits_per_sample integer,
    image_byte_order character varying DEFAULT ''::character varying,
    image_color_space character varying DEFAULT ''::character varying,
    image_compression_scheme character varying DEFAULT ''::character varying,
    text_character_set character varying DEFAULT ''::character varying,
    text_markup_basis character varying DEFAULT ''::character varying,
    text_markup_basis_version character varying DEFAULT ''::character varying,
    video_bit_depth integer,
    video_compressor character varying DEFAULT ''::character varying,
    video_compression_scheme character varying DEFAULT ''::character varying,
    video_sample_rate integer
);


--
-- Name: fits_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fits_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fits_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fits_data_id_seq OWNED BY fits_data.id;


--
-- Name: institutions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE institutions (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: institutions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE institutions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: institutions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE institutions_id_seq OWNED BY institutions.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE items (
    id integer NOT NULL,
    project_id integer,
    barcode character varying NOT NULL,
    bib_id character varying,
    oclc_number character varying,
    call_number character varying,
    title character varying,
    author character varying,
    imprint character varying,
    reformatting_date date,
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    local_title character varying DEFAULT ''::character varying,
    local_description text DEFAULT ''::text,
    batch character varying DEFAULT ''::character varying,
    file_count integer,
    reformatting_operator character varying DEFAULT ''::character varying,
    record_series_id character varying DEFAULT ''::character varying,
    archival_management_system_url character varying DEFAULT ''::character varying,
    series character varying DEFAULT ''::character varying,
    sub_series character varying DEFAULT ''::character varying,
    box character varying DEFAULT ''::character varying,
    folder character varying DEFAULT ''::character varying,
    item_title character varying DEFAULT ''::character varying,
    foldout_present boolean DEFAULT false NOT NULL,
    equipment character varying DEFAULT ''::character varying,
    status character varying,
    unique_identifier character varying,
    foldout_done boolean DEFAULT false NOT NULL,
    item_done boolean DEFAULT false NOT NULL,
    creator character varying,
    date character varying,
    rights_information text,
    item_number character varying,
    source_media character varying
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE items_id_seq OWNED BY items.id;


--
-- Name: job_amazon_backups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_amazon_backups (
    id integer NOT NULL,
    amazon_backup_id integer
);


--
-- Name: job_amazon_backups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_amazon_backups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_amazon_backups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_amazon_backups_id_seq OWNED BY job_amazon_backups.id;


--
-- Name: job_cfs_directory_export_cleanups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_cfs_directory_export_cleanups (
    id integer NOT NULL,
    directory character varying(255)
);


--
-- Name: job_cfs_directory_export_cleanups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_cfs_directory_export_cleanups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_cfs_directory_export_cleanups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_cfs_directory_export_cleanups_id_seq OWNED BY job_cfs_directory_export_cleanups.id;


--
-- Name: job_cfs_directory_exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_cfs_directory_exports (
    id integer NOT NULL,
    user_id integer,
    cfs_directory_id integer,
    uuid character varying(255),
    recursive boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: job_cfs_directory_exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_cfs_directory_exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_cfs_directory_exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_cfs_directory_exports_id_seq OWNED BY job_cfs_directory_exports.id;


--
-- Name: job_cfs_initial_directory_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_cfs_initial_directory_assessments (
    id integer NOT NULL,
    file_group_id integer,
    cfs_directory_id integer,
    file_count integer
);


--
-- Name: job_cfs_initial_directory_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_cfs_initial_directory_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_cfs_initial_directory_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_cfs_initial_directory_assessments_id_seq OWNED BY job_cfs_initial_directory_assessments.id;


--
-- Name: job_cfs_initial_file_group_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_cfs_initial_file_group_assessments (
    id integer NOT NULL,
    file_group_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: job_cfs_initial_file_group_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_cfs_initial_file_group_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_cfs_initial_file_group_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_cfs_initial_file_group_assessments_id_seq OWNED BY job_cfs_initial_file_group_assessments.id;


--
-- Name: job_fits_content_type_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_fits_content_type_batches (
    id integer NOT NULL,
    user_id integer,
    content_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_fits_content_type_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_fits_content_type_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_fits_content_type_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_fits_content_type_batches_id_seq OWNED BY job_fits_content_type_batches.id;


--
-- Name: job_fits_directories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_fits_directories (
    id integer NOT NULL,
    cfs_directory_id integer,
    file_group_id integer,
    file_count integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: job_fits_directories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_fits_directories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_fits_directories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_fits_directories_id_seq OWNED BY job_fits_directories.id;


--
-- Name: job_fits_directory_trees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_fits_directory_trees (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cfs_directory_id integer,
    file_group_id integer
);


--
-- Name: job_fits_directory_trees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_fits_directory_trees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_fits_directory_trees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_fits_directory_trees_id_seq OWNED BY job_fits_directory_trees.id;


--
-- Name: job_fits_file_extension_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_fits_file_extension_batches (
    id integer NOT NULL,
    user_id integer,
    file_extension_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_fits_file_extension_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_fits_file_extension_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_fits_file_extension_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_fits_file_extension_batches_id_seq OWNED BY job_fits_file_extension_batches.id;


--
-- Name: job_fixity_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_fixity_checks (
    id integer NOT NULL,
    user_id integer,
    fixity_checkable_id integer,
    fixity_checkable_type character varying,
    cfs_directory_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_fixity_checks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_fixity_checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_fixity_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_fixity_checks_id_seq OWNED BY job_fixity_checks.id;


--
-- Name: job_ingest_staging_deletes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_ingest_staging_deletes (
    id integer NOT NULL,
    external_file_group_id integer,
    user_id integer,
    path text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: job_ingest_staging_deletes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_ingest_staging_deletes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_ingest_staging_deletes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_ingest_staging_deletes_id_seq OWNED BY job_ingest_staging_deletes.id;


--
-- Name: job_item_bulk_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_item_bulk_imports (
    id integer NOT NULL,
    user_id integer,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    file_name character varying
);


--
-- Name: job_item_bulk_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_item_bulk_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_item_bulk_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_item_bulk_imports_id_seq OWNED BY job_item_bulk_imports.id;


--
-- Name: job_virus_scans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE job_virus_scans (
    id integer NOT NULL,
    file_group_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_virus_scans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_virus_scans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_virus_scans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_virus_scans_id_seq OWNED BY job_virus_scans.id;


--
-- Name: medusa_uuids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE medusa_uuids (
    id integer NOT NULL,
    uuid character varying(255),
    uuidable_id integer,
    uuidable_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: medusa_uuids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE medusa_uuids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: medusa_uuids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE medusa_uuids_id_seq OWNED BY medusa_uuids.id;


--
-- Name: package_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE package_profiles (
    id integer NOT NULL,
    name character varying(255),
    url character varying(255),
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: package_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE package_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: package_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE package_profiles_id_seq OWNED BY package_profiles.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE people (
    id integer NOT NULL,
    email character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE people_id_seq OWNED BY people.id;


--
-- Name: preservation_priorities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE preservation_priorities (
    id integer NOT NULL,
    name character varying(255),
    priority double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: preservation_priorities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE preservation_priorities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: preservation_priorities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE preservation_priorities_id_seq OWNED BY preservation_priorities.id;


--
-- Name: producers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE producers (
    id integer NOT NULL,
    title character varying(255),
    address_1 character varying(255),
    address_2 character varying(255),
    city character varying(255),
    state character varying(255),
    zip character varying(255),
    phone_number character varying(255),
    email character varying(255),
    url character varying(255),
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    administrator_id integer,
    notes_html text,
    active_start_date date,
    active_end_date date
);


--
-- Name: production_units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE production_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: production_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE production_units_id_seq OWNED BY producers.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE projects (
    id integer NOT NULL,
    manager_id integer NOT NULL,
    owner_id integer NOT NULL,
    start_date date NOT NULL,
    status character varying NOT NULL,
    title character varying NOT NULL,
    specifications text,
    summary text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    collection_id integer,
    external_id character varying DEFAULT ''::character varying
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: pronoms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pronoms (
    id integer NOT NULL,
    file_format_id integer,
    pronom_id character varying,
    version character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pronoms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pronoms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pronoms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pronoms_id_seq OWNED BY pronoms.id;


--
-- Name: red_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE red_flags (
    id integer NOT NULL,
    red_flaggable_id integer,
    red_flaggable_type character varying(255),
    message character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    notes text,
    priority character varying(255),
    status character varying(255)
);


--
-- Name: red_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE red_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: red_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE red_flags_id_seq OWNED BY red_flags.id;


--
-- Name: related_file_group_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE related_file_group_joins (
    id integer NOT NULL,
    source_file_group_id integer,
    target_file_group_id integer,
    note character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: related_file_group_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE related_file_group_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: related_file_group_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE related_file_group_joins_id_seq OWNED BY related_file_group_joins.id;


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE repositories (
    id integer NOT NULL,
    title character varying(255),
    url character varying(255),
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    address_1 character varying(255),
    address_2 character varying(255),
    city character varying(255),
    state character varying(255),
    zip character varying(255),
    phone_number character varying(255),
    email character varying(255),
    contact_id integer,
    notes_html text,
    active_start_date date,
    active_end_date date,
    ldap_admin_domain character varying(255),
    ldap_admin_group character varying(255),
    institution_id integer
);


--
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE repositories_id_seq OWNED BY repositories.id;


--
-- Name: resource_typeable_resource_type_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE resource_typeable_resource_type_joins (
    id integer NOT NULL,
    resource_typeable_id integer,
    resource_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    resource_typeable_type character varying(255)
);


--
-- Name: resource_typeable_resource_type_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE resource_typeable_resource_type_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_typeable_resource_type_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE resource_typeable_resource_type_joins_id_seq OWNED BY resource_typeable_resource_type_joins.id;


--
-- Name: resource_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE resource_types (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: resource_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE resource_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE resource_types_id_seq OWNED BY resource_types.id;


--
-- Name: rights_declarations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rights_declarations (
    id integer NOT NULL,
    rights_declarable_id integer,
    rights_declarable_type character varying(255),
    rights_basis character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    copyright_jurisdiction character varying(255),
    copyright_statement character varying(255),
    access_restrictions character varying(255),
    custom_copyright_statement text DEFAULT ''::text
);


--
-- Name: rights_declarations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rights_declarations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rights_declarations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rights_declarations_id_seq OWNED BY rights_declarations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sessions (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: static_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE static_pages (
    id integer NOT NULL,
    key character varying,
    page_text text DEFAULT ''::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: static_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE static_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: static_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE static_pages_id_seq OWNED BY static_pages.id;


--
-- Name: storage_media; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE storage_media (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: storage_media_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE storage_media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: storage_media_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE storage_media_id_seq OWNED BY storage_media.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    uid character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: view_bit_level_file_group_cfs_root_stats_two_ways; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_bit_level_file_group_cfs_root_stats_two_ways AS
 SELECT fg.id AS file_group_id,
    round((fg.total_file_size * (1073741824)::numeric)) AS file_group_size,
    fg.total_files AS file_group_count,
    d.id AS cfs_directory_id,
    d.tree_size AS cfs_directory_size,
    d.tree_count AS cfs_directory_count
   FROM (file_groups fg
     LEFT JOIN cfs_directories d ON ((fg.id = d.parent_id)))
  WHERE ((d.parent_type)::text = 'FileGroup'::text);


--
-- Name: view_cfs_directories_file_stats_two_ways; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_cfs_directories_file_stats_two_ways AS
 SELECT d.id,
    d.tree_count,
    d.tree_size,
    (( SELECT count(*) AS count
           FROM cfs_files f
          WHERE (f.cfs_directory_id = d.id)) + ( SELECT sum(COALESCE(sd.tree_count, 0)) AS sum
           FROM cfs_directories sd
          WHERE (((sd.parent_type)::text = 'CfsDirectory'::text) AND (sd.parent_id = d.id)))) AS computed_count,
    (( SELECT sum(COALESCE(f.size, (0)::numeric)) AS sum
           FROM cfs_files f
          WHERE (f.cfs_directory_id = d.id)) + ( SELECT sum(COALESCE(sd.tree_size, (0)::numeric)) AS sum
           FROM cfs_directories sd
          WHERE (((sd.parent_type)::text = 'CfsDirectory'::text) AND (sd.parent_id = d.id)))) AS computed_size
   FROM cfs_directories d;


--
-- Name: view_cfs_directories_inconsistent_file_stats; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_cfs_directories_inconsistent_file_stats AS
 SELECT view_cfs_directories_file_stats_two_ways.id,
    view_cfs_directories_file_stats_two_ways.tree_count,
    view_cfs_directories_file_stats_two_ways.tree_size,
    view_cfs_directories_file_stats_two_ways.computed_count,
    view_cfs_directories_file_stats_two_ways.computed_size
   FROM view_cfs_directories_file_stats_two_ways
  WHERE ((view_cfs_directories_file_stats_two_ways.tree_count <> view_cfs_directories_file_stats_two_ways.computed_count) OR (view_cfs_directories_file_stats_two_ways.tree_size <> view_cfs_directories_file_stats_two_ways.computed_size));


--
-- Name: view_cfs_files_to_parents; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_cfs_files_to_parents AS
 SELECT f.id AS cfs_file_id,
    d.id AS cfs_directory_id,
    rd.id AS root_cfs_directory_id,
    fg.id AS file_group_id,
    c.id AS collection_id,
    r.id AS repository_id,
    r.institution_id
   FROM cfs_files f,
    cfs_directories d,
    cfs_directories rd,
    file_groups fg,
    collections c,
    repositories r
  WHERE ((f.cfs_directory_id = d.id) AND (d.root_cfs_directory_id = rd.id) AND (rd.parent_id = fg.id) AND (fg.collection_id = c.id) AND (c.repository_id = r.id));


--
-- Name: view_file_content_type_stats_by_collection; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_file_content_type_stats_by_collection AS
 SELECT ct.id AS content_type_id,
    ct.name,
    p.collection_id,
    COALESCE(sum(COALESCE(f.size, (0)::numeric)), (0)::numeric) AS file_size,
    count(f.id) AS file_count
   FROM ((content_types ct
     JOIN cfs_files f ON ((ct.id = f.content_type_id)))
     JOIN view_cfs_files_to_parents p ON ((f.id = p.cfs_file_id)))
  GROUP BY ct.id, ct.name, p.collection_id
  ORDER BY ct.name;


--
-- Name: view_file_content_type_stats_by_repository; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_file_content_type_stats_by_repository AS
 SELECT ct.id AS content_type_id,
    ct.name,
    p.repository_id,
    COALESCE(sum(COALESCE(f.size, (0)::numeric)), (0)::numeric) AS file_size,
    count(f.id) AS file_count
   FROM ((content_types ct
     JOIN cfs_files f ON ((ct.id = f.content_type_id)))
     JOIN view_cfs_files_to_parents p ON ((f.id = p.cfs_file_id)))
  GROUP BY ct.id, ct.name, p.repository_id
  ORDER BY ct.name;


--
-- Name: view_file_extension_stats_by_collection; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_file_extension_stats_by_collection AS
 SELECT fe.id AS file_extension_id,
    fe.extension,
    p.collection_id,
    COALESCE(sum(COALESCE(f.size, (0)::numeric)), (0)::numeric) AS file_size,
    count(f.id) AS file_count
   FROM ((file_extensions fe
     JOIN cfs_files f ON ((fe.id = f.file_extension_id)))
     JOIN view_cfs_files_to_parents p ON ((f.id = p.cfs_file_id)))
  GROUP BY fe.id, fe.extension, p.collection_id
  ORDER BY fe.extension;


--
-- Name: view_file_extension_stats_by_repository; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_file_extension_stats_by_repository AS
 SELECT fe.id AS file_extension_id,
    fe.extension,
    p.repository_id,
    COALESCE(sum(COALESCE(f.size, (0)::numeric)), (0)::numeric) AS file_size,
    count(f.id) AS file_count
   FROM ((file_extensions fe
     JOIN cfs_files f ON ((fe.id = f.file_extension_id)))
     JOIN view_cfs_files_to_parents p ON ((f.id = p.cfs_file_id)))
  GROUP BY fe.id, fe.extension, p.repository_id
  ORDER BY fe.extension;


--
-- Name: view_file_group_dashboard_info; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_file_group_dashboard_info AS
 SELECT fg.id,
    fg.title,
    fg.total_files,
    fg.total_file_size,
    c.id AS collection_id,
    c.title AS collection_title,
    r.id AS repository_id,
    r.title AS repository_title
   FROM file_groups fg,
    collections c,
    repositories r,
    cfs_directories cfs
  WHERE (((fg.type)::text = 'BitLevelFileGroup'::text) AND (fg.collection_id = c.id) AND (c.repository_id = r.id) AND ((cfs.parent_type)::text = 'FileGroup'::text) AND (cfs.parent_id = fg.id))
  ORDER BY fg.id;


--
-- Name: view_file_groups_latest_amazon_backup; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_file_groups_latest_amazon_backup AS
 SELECT fg.id AS file_group_id,
    ab.part_count,
    ab.archive_ids,
    ab.date,
    r.id AS repository_id
   FROM amazon_backups ab,
    ( SELECT amazon_backups.cfs_directory_id,
            max(amazon_backups.date) AS max_date
           FROM amazon_backups
          GROUP BY amazon_backups.cfs_directory_id) ablu,
    cfs_directories cfs,
    file_groups fg,
    collections c,
    repositories r
  WHERE ((ab.cfs_directory_id = ablu.cfs_directory_id) AND (ab.date = ablu.max_date) AND (ab.part_count IS NOT NULL) AND (ab.archive_ids IS NOT NULL) AND (cfs.id = ab.cfs_directory_id) AND (fg.id = cfs.parent_id) AND ((cfs.parent_type)::text = 'FileGroup'::text) AND (fg.collection_id = c.id) AND (c.repository_id = r.id));


--
-- Name: view_tested_file_relations; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_tested_file_relations AS
 SELECT fft.id AS file_format_test_id,
    f.id AS cfs_file_id,
    f.content_type_id,
    f.file_extension_id,
    p.repository_id,
    p.collection_id
   FROM ((file_format_tests fft
     JOIN cfs_files f ON ((fft.cfs_file_id = f.id)))
     JOIN view_cfs_files_to_parents p ON ((f.id = p.cfs_file_id)));


--
-- Name: view_tested_file_content_type_counts; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_tested_file_content_type_counts AS
 SELECT view_tested_file_relations.content_type_id,
    view_tested_file_relations.repository_id,
    count(*) AS count
   FROM view_tested_file_relations
  GROUP BY view_tested_file_relations.content_type_id, view_tested_file_relations.repository_id;


--
-- Name: view_tested_file_content_type_counts_by_collection; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_tested_file_content_type_counts_by_collection AS
 SELECT view_tested_file_relations.content_type_id,
    view_tested_file_relations.collection_id,
    count(*) AS count
   FROM view_tested_file_relations
  GROUP BY view_tested_file_relations.content_type_id, view_tested_file_relations.collection_id;


--
-- Name: view_tested_file_file_extension_counts; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_tested_file_file_extension_counts AS
 SELECT view_tested_file_relations.file_extension_id,
    view_tested_file_relations.repository_id,
    count(*) AS count
   FROM view_tested_file_relations
  GROUP BY view_tested_file_relations.file_extension_id, view_tested_file_relations.repository_id;


--
-- Name: view_tested_file_file_extension_counts_by_collection; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW view_tested_file_file_extension_counts_by_collection AS
 SELECT view_tested_file_relations.file_extension_id,
    view_tested_file_relations.collection_id,
    count(*) AS count
   FROM view_tested_file_relations
  GROUP BY view_tested_file_relations.file_extension_id, view_tested_file_relations.collection_id;


--
-- Name: virtual_repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE virtual_repositories (
    id integer NOT NULL,
    title character varying,
    repository_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: virtual_repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE virtual_repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: virtual_repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE virtual_repositories_id_seq OWNED BY virtual_repositories.id;


--
-- Name: virus_scans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE virus_scans (
    id integer NOT NULL,
    file_group_id integer,
    scan_result text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: virus_scans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE virus_scans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: virus_scans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE virus_scans_id_seq OWNED BY virus_scans.id;


--
-- Name: workflow_accrual_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE workflow_accrual_comments (
    id integer NOT NULL,
    workflow_accrual_job_id integer,
    body text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: workflow_accrual_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workflow_accrual_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_accrual_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workflow_accrual_comments_id_seq OWNED BY workflow_accrual_comments.id;


--
-- Name: workflow_accrual_conflicts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE workflow_accrual_conflicts (
    id integer NOT NULL,
    workflow_accrual_job_id integer,
    path text,
    different boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: workflow_accrual_conflicts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workflow_accrual_conflicts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_accrual_conflicts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workflow_accrual_conflicts_id_seq OWNED BY workflow_accrual_conflicts.id;


--
-- Name: workflow_accrual_directories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE workflow_accrual_directories (
    id integer NOT NULL,
    workflow_accrual_job_id integer,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    size numeric DEFAULT 0,
    count integer DEFAULT 0
);


--
-- Name: workflow_accrual_directories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workflow_accrual_directories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_accrual_directories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workflow_accrual_directories_id_seq OWNED BY workflow_accrual_directories.id;


--
-- Name: workflow_accrual_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE workflow_accrual_files (
    id integer NOT NULL,
    workflow_accrual_job_id integer,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    size numeric DEFAULT 0
);


--
-- Name: workflow_accrual_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workflow_accrual_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_accrual_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workflow_accrual_files_id_seq OWNED BY workflow_accrual_files.id;


--
-- Name: workflow_accrual_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE workflow_accrual_jobs (
    id integer NOT NULL,
    cfs_directory_id integer,
    staging_path text,
    state character varying,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    amazon_backup_id integer
);


--
-- Name: workflow_accrual_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workflow_accrual_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_accrual_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workflow_accrual_jobs_id_seq OWNED BY workflow_accrual_jobs.id;


--
-- Name: workflow_ingests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE workflow_ingests (
    id integer NOT NULL,
    state character varying(255),
    external_file_group_id integer,
    bit_level_file_group_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    amazon_backup_id integer
);


--
-- Name: workflow_ingests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE workflow_ingests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_ingests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE workflow_ingests_id_seq OWNED BY workflow_ingests.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY access_system_collection_joins ALTER COLUMN id SET DEFAULT nextval('access_system_collection_joins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY access_systems ALTER COLUMN id SET DEFAULT nextval('access_systems_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY amazon_backups ALTER COLUMN id SET DEFAULT nextval('amazon_backups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY amqp_accrual_delete_jobs ALTER COLUMN id SET DEFAULT nextval('amqp_accrual_delete_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY amqp_accrual_ingest_jobs ALTER COLUMN id SET DEFAULT nextval('amqp_accrual_ingest_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY archived_accrual_jobs ALTER COLUMN id SET DEFAULT nextval('archived_accrual_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessments ALTER COLUMN id SET DEFAULT nextval('assessments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_tracker_items ALTER COLUMN id SET DEFAULT nextval('book_tracker_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_tracker_tasks ALTER COLUMN id SET DEFAULT nextval('book_tracker_tasks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cascaded_event_joins ALTER COLUMN id SET DEFAULT nextval('cascaded_event_joins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cascaded_red_flag_joins ALTER COLUMN id SET DEFAULT nextval('cascaded_red_flag_joins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cfs_directories ALTER COLUMN id SET DEFAULT nextval('cfs_directories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cfs_files ALTER COLUMN id SET DEFAULT nextval('cfs_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_virtual_repository_joins ALTER COLUMN id SET DEFAULT nextval('collection_virtual_repository_joins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collections ALTER COLUMN id SET DEFAULT nextval('collections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_types ALTER COLUMN id SET DEFAULT nextval('content_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloader_requests ALTER COLUMN id SET DEFAULT nextval('downloader_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_extensions ALTER COLUMN id SET DEFAULT nextval('file_extensions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_normalization_paths ALTER COLUMN id SET DEFAULT nextval('file_format_normalization_paths_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_notes ALTER COLUMN id SET DEFAULT nextval('file_format_notes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_profiles ALTER COLUMN id SET DEFAULT nextval('file_format_profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_profiles_content_types_joins ALTER COLUMN id SET DEFAULT nextval('file_format_profiles_content_types_joins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_profiles_file_extensions_joins ALTER COLUMN id SET DEFAULT nextval('file_format_profiles_file_extensions_joins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_test_reasons ALTER COLUMN id SET DEFAULT nextval('file_format_test_reasons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_tests ALTER COLUMN id SET DEFAULT nextval('file_format_tests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_tests_file_format_test_reasons_joins ALTER COLUMN id SET DEFAULT nextval('file_format_tests_file_format_test_reasons_joins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_formats ALTER COLUMN id SET DEFAULT nextval('file_formats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_groups ALTER COLUMN id SET DEFAULT nextval('file_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fits_data ALTER COLUMN id SET DEFAULT nextval('fits_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY institutions ALTER COLUMN id SET DEFAULT nextval('institutions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY items ALTER COLUMN id SET DEFAULT nextval('items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_amazon_backups ALTER COLUMN id SET DEFAULT nextval('job_amazon_backups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_cfs_directory_export_cleanups ALTER COLUMN id SET DEFAULT nextval('job_cfs_directory_export_cleanups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_cfs_directory_exports ALTER COLUMN id SET DEFAULT nextval('job_cfs_directory_exports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_cfs_initial_directory_assessments ALTER COLUMN id SET DEFAULT nextval('job_cfs_initial_directory_assessments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_cfs_initial_file_group_assessments ALTER COLUMN id SET DEFAULT nextval('job_cfs_initial_file_group_assessments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fits_content_type_batches ALTER COLUMN id SET DEFAULT nextval('job_fits_content_type_batches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fits_directories ALTER COLUMN id SET DEFAULT nextval('job_fits_directories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fits_directory_trees ALTER COLUMN id SET DEFAULT nextval('job_fits_directory_trees_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fits_file_extension_batches ALTER COLUMN id SET DEFAULT nextval('job_fits_file_extension_batches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fixity_checks ALTER COLUMN id SET DEFAULT nextval('job_fixity_checks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_ingest_staging_deletes ALTER COLUMN id SET DEFAULT nextval('job_ingest_staging_deletes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_item_bulk_imports ALTER COLUMN id SET DEFAULT nextval('job_item_bulk_imports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_virus_scans ALTER COLUMN id SET DEFAULT nextval('job_virus_scans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY medusa_uuids ALTER COLUMN id SET DEFAULT nextval('medusa_uuids_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY package_profiles ALTER COLUMN id SET DEFAULT nextval('package_profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY preservation_priorities ALTER COLUMN id SET DEFAULT nextval('preservation_priorities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY producers ALTER COLUMN id SET DEFAULT nextval('production_units_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pronoms ALTER COLUMN id SET DEFAULT nextval('pronoms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY red_flags ALTER COLUMN id SET DEFAULT nextval('red_flags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY related_file_group_joins ALTER COLUMN id SET DEFAULT nextval('related_file_group_joins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories ALTER COLUMN id SET DEFAULT nextval('repositories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY resource_typeable_resource_type_joins ALTER COLUMN id SET DEFAULT nextval('resource_typeable_resource_type_joins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY resource_types ALTER COLUMN id SET DEFAULT nextval('resource_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rights_declarations ALTER COLUMN id SET DEFAULT nextval('rights_declarations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY static_pages ALTER COLUMN id SET DEFAULT nextval('static_pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY storage_media ALTER COLUMN id SET DEFAULT nextval('storage_media_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY virtual_repositories ALTER COLUMN id SET DEFAULT nextval('virtual_repositories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY virus_scans ALTER COLUMN id SET DEFAULT nextval('virus_scans_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_comments ALTER COLUMN id SET DEFAULT nextval('workflow_accrual_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_conflicts ALTER COLUMN id SET DEFAULT nextval('workflow_accrual_conflicts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_directories ALTER COLUMN id SET DEFAULT nextval('workflow_accrual_directories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_files ALTER COLUMN id SET DEFAULT nextval('workflow_accrual_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_jobs ALTER COLUMN id SET DEFAULT nextval('workflow_accrual_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_ingests ALTER COLUMN id SET DEFAULT nextval('workflow_ingests_id_seq'::regclass);


--
-- Name: access_system_collection_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY access_system_collection_joins
    ADD CONSTRAINT access_system_collection_joins_pkey PRIMARY KEY (id);


--
-- Name: access_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY access_systems
    ADD CONSTRAINT access_systems_pkey PRIMARY KEY (id);


--
-- Name: amazon_backups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY amazon_backups
    ADD CONSTRAINT amazon_backups_pkey PRIMARY KEY (id);


--
-- Name: amqp_accrual_delete_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY amqp_accrual_delete_jobs
    ADD CONSTRAINT amqp_accrual_delete_jobs_pkey PRIMARY KEY (id);


--
-- Name: amqp_accrual_ingest_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY amqp_accrual_ingest_jobs
    ADD CONSTRAINT amqp_accrual_ingest_jobs_pkey PRIMARY KEY (id);


--
-- Name: archived_accrual_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY archived_accrual_jobs
    ADD CONSTRAINT archived_accrual_jobs_pkey PRIMARY KEY (id);


--
-- Name: assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessments
    ADD CONSTRAINT assessments_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: book_tracker_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_tracker_items
    ADD CONSTRAINT book_tracker_items_pkey PRIMARY KEY (id);


--
-- Name: book_tracker_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_tracker_tasks
    ADD CONSTRAINT book_tracker_tasks_pkey PRIMARY KEY (id);


--
-- Name: cascaded_event_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cascaded_event_joins
    ADD CONSTRAINT cascaded_event_joins_pkey PRIMARY KEY (id);


--
-- Name: cascaded_red_flag_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cascaded_red_flag_joins
    ADD CONSTRAINT cascaded_red_flag_joins_pkey PRIMARY KEY (id);


--
-- Name: cfs_directories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cfs_directories
    ADD CONSTRAINT cfs_directories_pkey PRIMARY KEY (id);


--
-- Name: cfs_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cfs_files
    ADD CONSTRAINT cfs_files_pkey PRIMARY KEY (id);


--
-- Name: collection_resource_type_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY resource_typeable_resource_type_joins
    ADD CONSTRAINT collection_resource_type_joins_pkey PRIMARY KEY (id);


--
-- Name: collection_virtual_repository_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_virtual_repository_joins
    ADD CONSTRAINT collection_virtual_repository_joins_pkey PRIMARY KEY (id);


--
-- Name: collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: content_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_types
    ADD CONSTRAINT content_types_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: downloader_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloader_requests
    ADD CONSTRAINT downloader_requests_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: file_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_extensions
    ADD CONSTRAINT file_extensions_pkey PRIMARY KEY (id);


--
-- Name: file_format_normalization_paths_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_normalization_paths
    ADD CONSTRAINT file_format_normalization_paths_pkey PRIMARY KEY (id);


--
-- Name: file_format_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_notes
    ADD CONSTRAINT file_format_notes_pkey PRIMARY KEY (id);


--
-- Name: file_format_profiles_content_types_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_profiles_content_types_joins
    ADD CONSTRAINT file_format_profiles_content_types_joins_pkey PRIMARY KEY (id);


--
-- Name: file_format_profiles_file_extensions_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_profiles_file_extensions_joins
    ADD CONSTRAINT file_format_profiles_file_extensions_joins_pkey PRIMARY KEY (id);


--
-- Name: file_format_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_profiles
    ADD CONSTRAINT file_format_profiles_pkey PRIMARY KEY (id);


--
-- Name: file_format_test_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_test_reasons
    ADD CONSTRAINT file_format_test_reasons_pkey PRIMARY KEY (id);


--
-- Name: file_format_tests_file_format_test_reasons_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_tests_file_format_test_reasons_joins
    ADD CONSTRAINT file_format_tests_file_format_test_reasons_joins_pkey PRIMARY KEY (id);


--
-- Name: file_format_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_tests
    ADD CONSTRAINT file_format_tests_pkey PRIMARY KEY (id);


--
-- Name: file_formats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_formats
    ADD CONSTRAINT file_formats_pkey PRIMARY KEY (id);


--
-- Name: file_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_groups
    ADD CONSTRAINT file_groups_pkey PRIMARY KEY (id);


--
-- Name: fits_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fits_data
    ADD CONSTRAINT fits_data_pkey PRIMARY KEY (id);


--
-- Name: institutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY institutions
    ADD CONSTRAINT institutions_pkey PRIMARY KEY (id);


--
-- Name: items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: job_amazon_backups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_amazon_backups
    ADD CONSTRAINT job_amazon_backups_pkey PRIMARY KEY (id);


--
-- Name: job_cfs_directory_export_cleanups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_cfs_directory_export_cleanups
    ADD CONSTRAINT job_cfs_directory_export_cleanups_pkey PRIMARY KEY (id);


--
-- Name: job_cfs_directory_exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_cfs_directory_exports
    ADD CONSTRAINT job_cfs_directory_exports_pkey PRIMARY KEY (id);


--
-- Name: job_cfs_initial_directory_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_cfs_initial_directory_assessments
    ADD CONSTRAINT job_cfs_initial_directory_assessments_pkey PRIMARY KEY (id);


--
-- Name: job_cfs_initial_file_group_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_cfs_initial_file_group_assessments
    ADD CONSTRAINT job_cfs_initial_file_group_assessments_pkey PRIMARY KEY (id);


--
-- Name: job_fits_content_type_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fits_content_type_batches
    ADD CONSTRAINT job_fits_content_type_batches_pkey PRIMARY KEY (id);


--
-- Name: job_fits_directories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fits_directories
    ADD CONSTRAINT job_fits_directories_pkey PRIMARY KEY (id);


--
-- Name: job_fits_directory_trees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fits_directory_trees
    ADD CONSTRAINT job_fits_directory_trees_pkey PRIMARY KEY (id);


--
-- Name: job_fits_file_extension_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fits_file_extension_batches
    ADD CONSTRAINT job_fits_file_extension_batches_pkey PRIMARY KEY (id);


--
-- Name: job_fixity_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fixity_checks
    ADD CONSTRAINT job_fixity_checks_pkey PRIMARY KEY (id);


--
-- Name: job_ingest_staging_deletes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_ingest_staging_deletes
    ADD CONSTRAINT job_ingest_staging_deletes_pkey PRIMARY KEY (id);


--
-- Name: job_item_bulk_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_item_bulk_imports
    ADD CONSTRAINT job_item_bulk_imports_pkey PRIMARY KEY (id);


--
-- Name: job_virus_scans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_virus_scans
    ADD CONSTRAINT job_virus_scans_pkey PRIMARY KEY (id);


--
-- Name: medusa_uuids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY medusa_uuids
    ADD CONSTRAINT medusa_uuids_pkey PRIMARY KEY (id);


--
-- Name: package_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY package_profiles
    ADD CONSTRAINT package_profiles_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: preservation_priorities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY preservation_priorities
    ADD CONSTRAINT preservation_priorities_pkey PRIMARY KEY (id);


--
-- Name: production_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY producers
    ADD CONSTRAINT production_units_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: pronoms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pronoms
    ADD CONSTRAINT pronoms_pkey PRIMARY KEY (id);


--
-- Name: red_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY red_flags
    ADD CONSTRAINT red_flags_pkey PRIMARY KEY (id);


--
-- Name: related_file_group_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY related_file_group_joins
    ADD CONSTRAINT related_file_group_joins_pkey PRIMARY KEY (id);


--
-- Name: repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: resource_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY resource_types
    ADD CONSTRAINT resource_types_pkey PRIMARY KEY (id);


--
-- Name: rights_declarations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rights_declarations
    ADD CONSTRAINT rights_declarations_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: static_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY static_pages
    ADD CONSTRAINT static_pages_pkey PRIMARY KEY (id);


--
-- Name: storage_media_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY storage_media
    ADD CONSTRAINT storage_media_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: virtual_repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY virtual_repositories
    ADD CONSTRAINT virtual_repositories_pkey PRIMARY KEY (id);


--
-- Name: virus_scans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY virus_scans
    ADD CONSTRAINT virus_scans_pkey PRIMARY KEY (id);


--
-- Name: workflow_accrual_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_comments
    ADD CONSTRAINT workflow_accrual_comments_pkey PRIMARY KEY (id);


--
-- Name: workflow_accrual_conflicts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_conflicts
    ADD CONSTRAINT workflow_accrual_conflicts_pkey PRIMARY KEY (id);


--
-- Name: workflow_accrual_directories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_directories
    ADD CONSTRAINT workflow_accrual_directories_pkey PRIMARY KEY (id);


--
-- Name: workflow_accrual_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_files
    ADD CONSTRAINT workflow_accrual_files_pkey PRIMARY KEY (id);


--
-- Name: workflow_accrual_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_jobs
    ADD CONSTRAINT workflow_accrual_jobs_pkey PRIMARY KEY (id);


--
-- Name: workflow_ingests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_ingests
    ADD CONSTRAINT workflow_ingests_pkey PRIMARY KEY (id);


--
-- Name: amqp_accrual_ingest_jobs_unique_client_and_path; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX amqp_accrual_ingest_jobs_unique_client_and_path ON amqp_accrual_ingest_jobs USING btree (client, staging_path);


--
-- Name: cfs_directory_parent_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cfs_directory_parent_idx ON cfs_directories USING btree (parent_type, parent_id, path);


--
-- Name: collection_virtual_repository_join_collection_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX collection_virtual_repository_join_collection_index ON collection_virtual_repository_joins USING btree (collection_id);


--
-- Name: collection_virtual_repository_join_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX collection_virtual_repository_join_unique_index ON collection_virtual_repository_joins USING btree (virtual_repository_id, collection_id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: ffpctj_content_type_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ffpctj_content_type_id_idx ON file_format_profiles_content_types_joins USING btree (content_type_id);


--
-- Name: ffpctj_file_format_profile_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ffpctj_file_format_profile_id_idx ON file_format_profiles_content_types_joins USING btree (file_format_profile_id);


--
-- Name: ffpfej_file_extension_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ffpfej_file_extension_id_idx ON file_format_profiles_file_extensions_joins USING btree (file_extension_id);


--
-- Name: ffpfej_file_format_profile_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ffpfej_file_format_profile_id_idx ON file_format_profiles_file_extensions_joins USING btree (file_format_profile_id);


--
-- Name: fft_fftr_joins_fftr_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fft_fftr_joins_fftr_id_index ON file_format_tests_file_format_test_reasons_joins USING btree (file_format_test_reason_id);


--
-- Name: fft_fftr_joins_unique_pairs; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX fft_fftr_joins_unique_pairs ON file_format_tests_file_format_test_reasons_joins USING btree (file_format_test_id, file_format_test_reason_id);


--
-- Name: fixity_object; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX fixity_object ON job_fixity_checks USING btree (fixity_checkable_id, fixity_checkable_type);


--
-- Name: idx_cfs_files_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cfs_files_lower_name ON cfs_files USING btree (lower((name)::text));


--
-- Name: index_access_system_collection_joins_on_access_system_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_system_collection_joins_on_access_system_id ON access_system_collection_joins USING btree (access_system_id);


--
-- Name: index_access_system_collection_joins_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_system_collection_joins_on_collection_id ON access_system_collection_joins USING btree (collection_id);


--
-- Name: index_access_system_collection_joins_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_system_collection_joins_on_updated_at ON access_system_collection_joins USING btree (updated_at);


--
-- Name: index_access_systems_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_systems_on_updated_at ON access_systems USING btree (updated_at);


--
-- Name: index_amazon_backups_on_cfs_directory_id_and_date; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_amazon_backups_on_cfs_directory_id_and_date ON amazon_backups USING btree (cfs_directory_id, date);


--
-- Name: index_amazon_backups_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_amazon_backups_on_updated_at ON amazon_backups USING btree (updated_at);


--
-- Name: index_amqp_accrual_delete_jobs_on_cfs_file_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_amqp_accrual_delete_jobs_on_cfs_file_uuid ON amqp_accrual_delete_jobs USING btree (cfs_file_uuid);


--
-- Name: index_amqp_accrual_delete_jobs_on_client; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_amqp_accrual_delete_jobs_on_client ON amqp_accrual_delete_jobs USING btree (client);


--
-- Name: index_archived_accrual_jobs_on_amazon_backup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_archived_accrual_jobs_on_amazon_backup_id ON archived_accrual_jobs USING btree (amazon_backup_id);


--
-- Name: index_archived_accrual_jobs_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_archived_accrual_jobs_on_cfs_directory_id ON archived_accrual_jobs USING btree (cfs_directory_id);


--
-- Name: index_archived_accrual_jobs_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_archived_accrual_jobs_on_file_group_id ON archived_accrual_jobs USING btree (file_group_id);


--
-- Name: index_archived_accrual_jobs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_archived_accrual_jobs_on_user_id ON archived_accrual_jobs USING btree (user_id);


--
-- Name: index_assessments_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessments_on_author_id ON assessments USING btree (author_id);


--
-- Name: index_assessments_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessments_on_collection_id ON assessments USING btree (assessable_id);


--
-- Name: index_assessments_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessments_on_updated_at ON assessments USING btree (updated_at);


--
-- Name: index_attachments_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachments_on_updated_at ON attachments USING btree (updated_at);


--
-- Name: index_book_tracker_items_on_author; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_tracker_items_on_author ON book_tracker_items USING btree (author);


--
-- Name: index_book_tracker_items_on_bib_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_tracker_items_on_bib_id ON book_tracker_items USING btree (bib_id);


--
-- Name: index_book_tracker_items_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_tracker_items_on_date ON book_tracker_items USING btree (date);


--
-- Name: index_book_tracker_items_on_exists_in_hathitrust; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_tracker_items_on_exists_in_hathitrust ON book_tracker_items USING btree (exists_in_hathitrust);


--
-- Name: index_book_tracker_items_on_exists_in_internet_archive; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_tracker_items_on_exists_in_internet_archive ON book_tracker_items USING btree (exists_in_internet_archive);


--
-- Name: index_book_tracker_items_on_ia_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_tracker_items_on_ia_identifier ON book_tracker_items USING btree (ia_identifier);


--
-- Name: index_book_tracker_items_on_obj_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_tracker_items_on_obj_id ON book_tracker_items USING btree (obj_id);


--
-- Name: index_book_tracker_items_on_oclc_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_tracker_items_on_oclc_number ON book_tracker_items USING btree (oclc_number);


--
-- Name: index_book_tracker_items_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_tracker_items_on_title ON book_tracker_items USING btree (title);


--
-- Name: index_book_tracker_items_on_volume; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_tracker_items_on_volume ON book_tracker_items USING btree (volume);


--
-- Name: index_cascaded_event_joins_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cascaded_event_joins_on_event_id ON cascaded_event_joins USING btree (event_id);


--
-- Name: index_cascaded_red_flag_joins_on_red_flag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cascaded_red_flag_joins_on_red_flag_id ON cascaded_red_flag_joins USING btree (red_flag_id);


--
-- Name: index_cfs_directories_on_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_directories_on_path ON cfs_directories USING btree (path);


--
-- Name: index_cfs_directories_on_root_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_directories_on_root_cfs_directory_id ON cfs_directories USING btree (root_cfs_directory_id);


--
-- Name: index_cfs_directories_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_directories_on_updated_at ON cfs_directories USING btree (updated_at);


--
-- Name: index_cfs_files_on_cfs_directory_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_cfs_files_on_cfs_directory_id_and_name ON cfs_files USING btree (cfs_directory_id, name);


--
-- Name: index_cfs_files_on_content_type_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_content_type_id_and_name ON cfs_files USING btree (content_type_id, name);


--
-- Name: index_cfs_files_on_file_extension_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_file_extension_id_and_name ON cfs_files USING btree (file_extension_id, name);


--
-- Name: index_cfs_files_on_fits_serialized; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_fits_serialized ON cfs_files USING btree (fits_serialized);


--
-- Name: index_cfs_files_on_fixity_check_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_fixity_check_status ON cfs_files USING btree (fixity_check_status);


--
-- Name: index_cfs_files_on_fixity_check_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_fixity_check_time ON cfs_files USING btree (fixity_check_time);


--
-- Name: index_cfs_files_on_mtime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_mtime ON cfs_files USING btree (mtime);


--
-- Name: index_cfs_files_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_name ON cfs_files USING btree (name);


--
-- Name: index_cfs_files_on_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_size ON cfs_files USING btree (size);


--
-- Name: index_cfs_files_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_updated_at ON cfs_files USING btree (updated_at);


--
-- Name: index_collections_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_contact_id ON collections USING btree (contact_id);


--
-- Name: index_collections_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_external_id ON collections USING btree (external_id);


--
-- Name: index_collections_on_publish; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_publish ON collections USING btree (publish);


--
-- Name: index_collections_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_repository_id ON collections USING btree (repository_id);


--
-- Name: index_collections_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_updated_at ON collections USING btree (updated_at);


--
-- Name: index_content_types_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_types_on_name ON content_types USING btree (name);


--
-- Name: index_downloader_requests_on_downloader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_downloader_requests_on_downloader_id ON downloader_requests USING btree (downloader_id);


--
-- Name: index_downloader_requests_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_downloader_requests_on_status ON downloader_requests USING btree (status);


--
-- Name: index_events_on_actor_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_actor_email ON events USING btree (actor_email);


--
-- Name: index_events_on_cascadable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_cascadable ON events USING btree (cascadable);


--
-- Name: index_events_on_eventable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_eventable_id ON events USING btree (eventable_id);


--
-- Name: index_events_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_updated_at ON events USING btree (updated_at);


--
-- Name: index_file_extensions_on_extension; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_file_extensions_on_extension ON file_extensions USING btree (extension);


--
-- Name: index_file_format_normalization_paths_on_file_format_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_format_normalization_paths_on_file_format_id ON file_format_normalization_paths USING btree (file_format_id);


--
-- Name: index_file_format_normalization_paths_on_output_format_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_format_normalization_paths_on_output_format_id ON file_format_normalization_paths USING btree (output_format_id);


--
-- Name: index_file_format_notes_on_file_format_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_format_notes_on_file_format_id ON file_format_notes USING btree (file_format_id);


--
-- Name: index_file_format_notes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_format_notes_on_user_id ON file_format_notes USING btree (user_id);


--
-- Name: index_file_format_profiles_on_file_format_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_format_profiles_on_file_format_id ON file_format_profiles USING btree (file_format_id);


--
-- Name: index_file_format_profiles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_file_format_profiles_on_name ON file_format_profiles USING btree (name);


--
-- Name: index_file_format_tests_on_cfs_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_file_format_tests_on_cfs_file_id ON file_format_tests USING btree (cfs_file_id);


--
-- Name: index_file_format_tests_on_file_format_profile_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_format_tests_on_file_format_profile_id ON file_format_tests USING btree (file_format_profile_id);


--
-- Name: index_file_groups_on_acquisition_method; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_groups_on_acquisition_method ON file_groups USING btree (acquisition_method);


--
-- Name: index_file_groups_on_cfs_root; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_file_groups_on_cfs_root ON file_groups USING btree (cfs_root);


--
-- Name: index_file_groups_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_groups_on_collection_id ON file_groups USING btree (collection_id);


--
-- Name: index_file_groups_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_groups_on_external_id ON file_groups USING btree (external_id);


--
-- Name: index_file_groups_on_package_profile_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_groups_on_package_profile_id ON file_groups USING btree (package_profile_id);


--
-- Name: index_file_groups_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_groups_on_type ON file_groups USING btree (type);


--
-- Name: index_file_groups_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_groups_on_updated_at ON file_groups USING btree (updated_at);


--
-- Name: index_fits_data_on_cfs_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_fits_data_on_cfs_file_id ON fits_data USING btree (cfs_file_id);


--
-- Name: index_institutions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_institutions_on_name ON institutions USING btree (name);


--
-- Name: index_institutions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_institutions_on_updated_at ON institutions USING btree (updated_at);


--
-- Name: index_items_on_barcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_barcode ON items USING btree (barcode);


--
-- Name: index_items_on_bib_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_bib_id ON items USING btree (bib_id);


--
-- Name: index_items_on_call_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_call_number ON items USING btree (call_number);


--
-- Name: index_items_on_oclc_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_oclc_number ON items USING btree (oclc_number);


--
-- Name: index_items_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_project_id ON items USING btree (project_id);


--
-- Name: index_items_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_status ON items USING btree (status);


--
-- Name: index_job_amazon_backups_on_amazon_backup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_job_amazon_backups_on_amazon_backup_id ON job_amazon_backups USING btree (amazon_backup_id);


--
-- Name: index_job_cfs_initial_directory_assessments_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_cfs_initial_directory_assessments_on_cfs_directory_id ON job_cfs_initial_directory_assessments USING btree (cfs_directory_id);


--
-- Name: index_job_cfs_initial_directory_assessments_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_cfs_initial_directory_assessments_on_file_group_id ON job_cfs_initial_directory_assessments USING btree (file_group_id);


--
-- Name: index_job_cfs_initial_file_group_assessments_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_cfs_initial_file_group_assessments_on_file_group_id ON job_cfs_initial_file_group_assessments USING btree (file_group_id);


--
-- Name: index_job_fits_content_type_batches_on_content_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_job_fits_content_type_batches_on_content_type_id ON job_fits_content_type_batches USING btree (content_type_id);


--
-- Name: index_job_fits_content_type_batches_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fits_content_type_batches_on_user_id ON job_fits_content_type_batches USING btree (user_id);


--
-- Name: index_job_fits_directories_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fits_directories_on_cfs_directory_id ON job_fits_directories USING btree (cfs_directory_id);


--
-- Name: index_job_fits_directories_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fits_directories_on_file_group_id ON job_fits_directories USING btree (file_group_id);


--
-- Name: index_job_fits_directory_trees_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fits_directory_trees_on_cfs_directory_id ON job_fits_directory_trees USING btree (cfs_directory_id);


--
-- Name: index_job_fits_directory_trees_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fits_directory_trees_on_file_group_id ON job_fits_directory_trees USING btree (file_group_id);


--
-- Name: index_job_fits_file_extension_batches_on_file_extension_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_job_fits_file_extension_batches_on_file_extension_id ON job_fits_file_extension_batches USING btree (file_extension_id);


--
-- Name: index_job_fits_file_extension_batches_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fits_file_extension_batches_on_user_id ON job_fits_file_extension_batches USING btree (user_id);


--
-- Name: index_job_fixity_checks_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fixity_checks_on_cfs_directory_id ON job_fixity_checks USING btree (cfs_directory_id);


--
-- Name: index_job_fixity_checks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fixity_checks_on_user_id ON job_fixity_checks USING btree (user_id);


--
-- Name: index_job_ingest_staging_deletes_on_external_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_ingest_staging_deletes_on_external_file_group_id ON job_ingest_staging_deletes USING btree (external_file_group_id);


--
-- Name: index_job_ingest_staging_deletes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_ingest_staging_deletes_on_user_id ON job_ingest_staging_deletes USING btree (user_id);


--
-- Name: index_job_item_bulk_imports_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_item_bulk_imports_on_project_id ON job_item_bulk_imports USING btree (project_id);


--
-- Name: index_job_item_bulk_imports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_item_bulk_imports_on_user_id ON job_item_bulk_imports USING btree (user_id);


--
-- Name: index_job_virus_scans_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_virus_scans_on_updated_at ON job_virus_scans USING btree (updated_at);


--
-- Name: index_medusa_uuids_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_medusa_uuids_on_uuid ON medusa_uuids USING btree (uuid);


--
-- Name: index_medusa_uuids_on_uuidable_id_and_uuidable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_medusa_uuids_on_uuidable_id_and_uuidable_type ON medusa_uuids USING btree (uuidable_id, uuidable_type);


--
-- Name: index_package_profiles_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_package_profiles_on_updated_at ON package_profiles USING btree (updated_at);


--
-- Name: index_people_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_email ON people USING btree (email);


--
-- Name: index_people_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_updated_at ON people USING btree (updated_at);


--
-- Name: index_preservation_priorities_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_preservation_priorities_on_updated_at ON preservation_priorities USING btree (updated_at);


--
-- Name: index_producers_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_producers_on_updated_at ON producers USING btree (updated_at);


--
-- Name: index_production_units_on_administrator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_production_units_on_administrator_id ON producers USING btree (administrator_id);


--
-- Name: index_projects_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_collection_id ON projects USING btree (collection_id);


--
-- Name: index_pronoms_on_file_format_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pronoms_on_file_format_id ON pronoms USING btree (file_format_id);


--
-- Name: index_red_flags_on_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_red_flags_on_priority ON red_flags USING btree (priority);


--
-- Name: index_red_flags_on_red_flaggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_red_flags_on_red_flaggable_id ON red_flags USING btree (red_flaggable_id);


--
-- Name: index_red_flags_on_red_flaggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_red_flags_on_red_flaggable_type ON red_flags USING btree (red_flaggable_type);


--
-- Name: index_red_flags_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_red_flags_on_status ON red_flags USING btree (status);


--
-- Name: index_red_flags_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_red_flags_on_updated_at ON red_flags USING btree (updated_at);


--
-- Name: index_related_file_group_joins_on_source_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_file_group_joins_on_source_file_group_id ON related_file_group_joins USING btree (source_file_group_id);


--
-- Name: index_related_file_group_joins_on_target_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_file_group_joins_on_target_file_group_id ON related_file_group_joins USING btree (target_file_group_id);


--
-- Name: index_related_file_group_joins_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_file_group_joins_on_updated_at ON related_file_group_joins USING btree (updated_at);


--
-- Name: index_repositories_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_contact_id ON repositories USING btree (contact_id);


--
-- Name: index_repositories_on_institution_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_institution_id ON repositories USING btree (institution_id);


--
-- Name: index_repositories_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_updated_at ON repositories USING btree (updated_at);


--
-- Name: index_resource_typeable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_typeable_id ON resource_typeable_resource_type_joins USING btree (resource_typeable_id);


--
-- Name: index_resource_typeable_resource_type_joins_on_resource_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_typeable_resource_type_joins_on_resource_type_id ON resource_typeable_resource_type_joins USING btree (resource_type_id);


--
-- Name: index_resource_typeable_resource_type_joins_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_typeable_resource_type_joins_on_updated_at ON resource_typeable_resource_type_joins USING btree (updated_at);


--
-- Name: index_resource_types_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_types_on_updated_at ON resource_types USING btree (updated_at);


--
-- Name: index_rights_declarations_on_rights_declarable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rights_declarations_on_rights_declarable_id ON rights_declarations USING btree (rights_declarable_id);


--
-- Name: index_rights_declarations_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rights_declarations_on_updated_at ON rights_declarations USING btree (updated_at);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_storage_media_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_storage_media_on_updated_at ON storage_media USING btree (updated_at);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_uid ON users USING btree (uid);


--
-- Name: index_users_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_updated_at ON users USING btree (updated_at);


--
-- Name: index_virus_scans_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_virus_scans_on_file_group_id ON virus_scans USING btree (file_group_id);


--
-- Name: index_virus_scans_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_virus_scans_on_updated_at ON virus_scans USING btree (updated_at);


--
-- Name: index_workflow_accrual_comments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_comments_on_user_id ON workflow_accrual_comments USING btree (user_id);


--
-- Name: index_workflow_accrual_comments_on_workflow_accrual_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_comments_on_workflow_accrual_job_id ON workflow_accrual_comments USING btree (workflow_accrual_job_id);


--
-- Name: index_workflow_accrual_conflicts_on_different; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_conflicts_on_different ON workflow_accrual_conflicts USING btree (different);


--
-- Name: index_workflow_accrual_conflicts_on_workflow_accrual_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_conflicts_on_workflow_accrual_job_id ON workflow_accrual_conflicts USING btree (workflow_accrual_job_id);


--
-- Name: index_workflow_accrual_directories_on_workflow_accrual_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_directories_on_workflow_accrual_job_id ON workflow_accrual_directories USING btree (workflow_accrual_job_id);


--
-- Name: index_workflow_accrual_files_on_workflow_accrual_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_files_on_workflow_accrual_job_id ON workflow_accrual_files USING btree (workflow_accrual_job_id);


--
-- Name: index_workflow_accrual_jobs_on_amazon_backup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_jobs_on_amazon_backup_id ON workflow_accrual_jobs USING btree (amazon_backup_id);


--
-- Name: index_workflow_accrual_jobs_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_jobs_on_cfs_directory_id ON workflow_accrual_jobs USING btree (cfs_directory_id);


--
-- Name: index_workflow_accrual_jobs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_jobs_on_user_id ON workflow_accrual_jobs USING btree (user_id);


--
-- Name: index_workflow_ingests_on_amazon_backup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_ingests_on_amazon_backup_id ON workflow_ingests USING btree (amazon_backup_id);


--
-- Name: index_workflow_ingests_on_bit_level_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_ingests_on_bit_level_file_group_id ON workflow_ingests USING btree (bit_level_file_group_id);


--
-- Name: index_workflow_ingests_on_external_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_workflow_ingests_on_external_file_group_id ON workflow_ingests USING btree (external_file_group_id);


--
-- Name: index_workflow_ingests_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_ingests_on_updated_at ON workflow_ingests USING btree (updated_at);


--
-- Name: index_workflow_ingests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_ingests_on_user_id ON workflow_ingests USING btree (user_id);


--
-- Name: unique_cascaded_events; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_cascaded_events ON cascaded_event_joins USING btree (cascaded_eventable_type, cascaded_eventable_id, event_id);


--
-- Name: unique_cascaded_red_flags; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_cascaded_red_flags ON cascaded_red_flag_joins USING btree (cascaded_red_flaggable_type, cascaded_red_flaggable_id, red_flag_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: wfad_job_and_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX wfad_job_and_name_idx ON workflow_accrual_directories USING btree (workflow_accrual_job_id, name);


--
-- Name: wfaf_job_and_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX wfaf_job_and_name_idx ON workflow_accrual_files USING btree (workflow_accrual_job_id, name);


--
-- Name: wfaj_cfs_dir_id_and_staging_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX wfaj_cfs_dir_id_and_staging_path_idx ON workflow_accrual_jobs USING btree (cfs_directory_id, staging_path);


--
-- Name: access_system_collection_joins_touch_access_system_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER access_system_collection_joins_touch_access_system_trigger AFTER INSERT OR DELETE OR UPDATE ON access_system_collection_joins FOR EACH ROW EXECUTE PROCEDURE access_system_collection_joins_touch_access_system();


--
-- Name: access_system_collection_joins_touch_collection_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER access_system_collection_joins_touch_collection_trigger AFTER INSERT OR DELETE OR UPDATE ON access_system_collection_joins FOR EACH ROW EXECUTE PROCEDURE access_system_collection_joins_touch_collection();


--
-- Name: amazon_backups_touch_cfs_directory_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER amazon_backups_touch_cfs_directory_trigger AFTER INSERT OR DELETE OR UPDATE ON amazon_backups FOR EACH ROW EXECUTE PROCEDURE amazon_backups_touch_cfs_directory();


--
-- Name: amazon_backups_touch_user_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER amazon_backups_touch_user_trigger AFTER INSERT OR DELETE OR UPDATE ON amazon_backups FOR EACH ROW EXECUTE PROCEDURE amazon_backups_touch_user();


--
-- Name: assessments_touch_storage_medium_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER assessments_touch_storage_medium_trigger AFTER INSERT OR DELETE OR UPDATE ON assessments FOR EACH ROW EXECUTE PROCEDURE assessments_touch_storage_medium();


--
-- Name: cfs_dir_update_bit_level_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cfs_dir_update_bit_level_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON cfs_directories FOR EACH ROW EXECUTE PROCEDURE cfs_dir_update_bit_level_file_group();


--
-- Name: cfs_dir_update_cfs_dir_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cfs_dir_update_cfs_dir_trigger AFTER INSERT OR DELETE OR UPDATE ON cfs_directories FOR EACH ROW EXECUTE PROCEDURE cfs_dir_update_cfs_dir();


--
-- Name: cfs_file_update_cfs_directory_and_extension_and_content_type_tr; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cfs_file_update_cfs_directory_and_extension_and_content_type_tr AFTER INSERT OR DELETE OR UPDATE ON cfs_files FOR EACH ROW EXECUTE PROCEDURE cfs_file_update_cfs_directory_and_extension_and_content_type();


--
-- Name: cfs_files_touch_cfs_directory_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cfs_files_touch_cfs_directory_trigger AFTER INSERT OR DELETE OR UPDATE ON cfs_files FOR EACH ROW EXECUTE PROCEDURE cfs_files_touch_cfs_directory();


--
-- Name: cfs_files_touch_content_type_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cfs_files_touch_content_type_trigger AFTER INSERT OR DELETE OR UPDATE ON cfs_files FOR EACH ROW EXECUTE PROCEDURE cfs_files_touch_content_type();


--
-- Name: cfs_files_touch_file_extension_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cfs_files_touch_file_extension_trigger AFTER INSERT OR DELETE OR UPDATE ON cfs_files FOR EACH ROW EXECUTE PROCEDURE cfs_files_touch_file_extension();


--
-- Name: collections_touch_preservation_priority_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER collections_touch_preservation_priority_trigger AFTER INSERT OR DELETE OR UPDATE ON collections FOR EACH ROW EXECUTE PROCEDURE collections_touch_preservation_priority();


--
-- Name: collections_touch_repository_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER collections_touch_repository_trigger AFTER INSERT OR DELETE OR UPDATE ON collections FOR EACH ROW EXECUTE PROCEDURE collections_touch_repository();


--
-- Name: file_groups_touch_collection_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER file_groups_touch_collection_trigger AFTER INSERT OR DELETE OR UPDATE ON file_groups FOR EACH ROW EXECUTE PROCEDURE file_groups_touch_collection();


--
-- Name: file_groups_touch_package_profile_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER file_groups_touch_package_profile_trigger AFTER INSERT OR DELETE OR UPDATE ON file_groups FOR EACH ROW EXECUTE PROCEDURE file_groups_touch_package_profile();


--
-- Name: file_groups_touch_producer_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER file_groups_touch_producer_trigger AFTER INSERT OR DELETE OR UPDATE ON file_groups FOR EACH ROW EXECUTE PROCEDURE file_groups_touch_producer();


--
-- Name: job_cfs_directory_exports_touch_cfs_directory_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_cfs_directory_exports_touch_cfs_directory_trigger AFTER INSERT OR DELETE OR UPDATE ON job_cfs_directory_exports FOR EACH ROW EXECUTE PROCEDURE job_cfs_directory_exports_touch_cfs_directory();


--
-- Name: job_cfs_directory_exports_touch_user_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_cfs_directory_exports_touch_user_trigger AFTER INSERT OR DELETE OR UPDATE ON job_cfs_directory_exports FOR EACH ROW EXECUTE PROCEDURE job_cfs_directory_exports_touch_user();


--
-- Name: job_cfs_initial_file_group_assessments_touch_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_cfs_initial_file_group_assessments_touch_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON job_cfs_initial_file_group_assessments FOR EACH ROW EXECUTE PROCEDURE job_cfs_initial_file_group_assessments_touch_file_group();


--
-- Name: job_fits_directories_touch_cfs_directory_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_fits_directories_touch_cfs_directory_trigger AFTER INSERT OR DELETE OR UPDATE ON job_fits_directories FOR EACH ROW EXECUTE PROCEDURE job_fits_directories_touch_cfs_directory();


--
-- Name: job_fits_directories_touch_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_fits_directories_touch_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON job_fits_directories FOR EACH ROW EXECUTE PROCEDURE job_fits_directories_touch_file_group();


--
-- Name: job_fits_directory_trees_touch_cfs_directory_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_fits_directory_trees_touch_cfs_directory_trigger AFTER INSERT OR DELETE OR UPDATE ON job_fits_directory_trees FOR EACH ROW EXECUTE PROCEDURE job_fits_directory_trees_touch_cfs_directory();


--
-- Name: job_fits_directory_trees_touch_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_fits_directory_trees_touch_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON job_fits_directory_trees FOR EACH ROW EXECUTE PROCEDURE job_fits_directory_trees_touch_file_group();


--
-- Name: job_ingest_staging_deletes_touch_external_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_ingest_staging_deletes_touch_external_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON job_ingest_staging_deletes FOR EACH ROW EXECUTE PROCEDURE job_ingest_staging_deletes_touch_external_file_group();


--
-- Name: job_ingest_staging_deletes_touch_user_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_ingest_staging_deletes_touch_user_trigger AFTER INSERT OR DELETE OR UPDATE ON job_ingest_staging_deletes FOR EACH ROW EXECUTE PROCEDURE job_ingest_staging_deletes_touch_user();


--
-- Name: job_virus_scans_touch_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_virus_scans_touch_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON job_virus_scans FOR EACH ROW EXECUTE PROCEDURE job_virus_scans_touch_file_group();


--
-- Name: projects_touch_collection_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER projects_touch_collection_trigger AFTER INSERT OR DELETE OR UPDATE ON projects FOR EACH ROW EXECUTE PROCEDURE projects_touch_collection();


--
-- Name: related_file_group_joins_touch_source_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER related_file_group_joins_touch_source_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON related_file_group_joins FOR EACH ROW EXECUTE PROCEDURE related_file_group_joins_touch_source_file_group();


--
-- Name: related_file_group_joins_touch_target_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER related_file_group_joins_touch_target_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON related_file_group_joins FOR EACH ROW EXECUTE PROCEDURE related_file_group_joins_touch_target_file_group();


--
-- Name: repositories_touch_institution_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER repositories_touch_institution_trigger AFTER INSERT OR DELETE OR UPDATE ON repositories FOR EACH ROW EXECUTE PROCEDURE repositories_touch_institution();


--
-- Name: resource_typeable_resource_type_joins_touch_resource_type_trigg; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER resource_typeable_resource_type_joins_touch_resource_type_trigg AFTER INSERT OR DELETE OR UPDATE ON resource_typeable_resource_type_joins FOR EACH ROW EXECUTE PROCEDURE resource_typeable_resource_type_joins_touch_resource_type();


--
-- Name: virus_scans_touch_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER virus_scans_touch_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON virus_scans FOR EACH ROW EXECUTE PROCEDURE virus_scans_touch_file_group();


--
-- Name: workflow_accrual_comments_touch_workflow_accrual_job_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_comments_touch_workflow_accrual_job_trigger AFTER INSERT OR DELETE OR UPDATE ON workflow_accrual_comments FOR EACH ROW EXECUTE PROCEDURE workflow_accrual_comments_touch_workflow_accrual_job();


--
-- Name: workflow_accrual_conflicts_touch_workflow_accrual_job_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_conflicts_touch_workflow_accrual_job_trigger AFTER INSERT OR DELETE OR UPDATE ON workflow_accrual_conflicts FOR EACH ROW EXECUTE PROCEDURE workflow_accrual_conflicts_touch_workflow_accrual_job();


--
-- Name: workflow_accrual_directories_touch_workflow_accrual_job_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_directories_touch_workflow_accrual_job_trigger AFTER INSERT OR DELETE OR UPDATE ON workflow_accrual_directories FOR EACH ROW EXECUTE PROCEDURE workflow_accrual_directories_touch_workflow_accrual_job();


--
-- Name: workflow_accrual_files_touch_workflow_accrual_job_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_files_touch_workflow_accrual_job_trigger AFTER INSERT OR DELETE OR UPDATE ON workflow_accrual_files FOR EACH ROW EXECUTE PROCEDURE workflow_accrual_files_touch_workflow_accrual_job();


--
-- Name: workflow_accrual_jobs_touch_amazon_backup_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_jobs_touch_amazon_backup_trigger AFTER INSERT OR DELETE OR UPDATE ON workflow_accrual_jobs FOR EACH ROW EXECUTE PROCEDURE workflow_accrual_jobs_touch_amazon_backup();


--
-- Name: workflow_accrual_jobs_touch_cfs_directory_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_jobs_touch_cfs_directory_trigger AFTER INSERT OR DELETE OR UPDATE ON workflow_accrual_jobs FOR EACH ROW EXECUTE PROCEDURE workflow_accrual_jobs_touch_cfs_directory();


--
-- Name: workflow_accrual_jobs_touch_user_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_jobs_touch_user_trigger AFTER INSERT OR DELETE OR UPDATE ON workflow_accrual_jobs FOR EACH ROW EXECUTE PROCEDURE workflow_accrual_jobs_touch_user();


--
-- Name: workflow_ingests_touch_amazon_backup_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_ingests_touch_amazon_backup_trigger AFTER INSERT OR DELETE OR UPDATE ON workflow_ingests FOR EACH ROW EXECUTE PROCEDURE workflow_ingests_touch_amazon_backup();


--
-- Name: workflow_ingests_touch_bit_level_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_ingests_touch_bit_level_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON workflow_ingests FOR EACH ROW EXECUTE PROCEDURE workflow_ingests_touch_bit_level_file_group();


--
-- Name: workflow_ingests_touch_external_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_ingests_touch_external_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON workflow_ingests FOR EACH ROW EXECUTE PROCEDURE workflow_ingests_touch_external_file_group();


--
-- Name: workflow_ingests_touch_user_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_ingests_touch_user_trigger AFTER INSERT OR DELETE OR UPDATE ON workflow_ingests FOR EACH ROW EXECUTE PROCEDURE workflow_ingests_touch_user();


--
-- Name: fk_rails_05018793e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cascaded_event_joins
    ADD CONSTRAINT fk_rails_05018793e6 FOREIGN KEY (event_id) REFERENCES events(id);


--
-- Name: fk_rails_1db34f98ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_tests_file_format_test_reasons_joins
    ADD CONSTRAINT fk_rails_1db34f98ff FOREIGN KEY (file_format_test_id) REFERENCES file_format_tests(id);


--
-- Name: fk_rails_2258e947c4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_comments
    ADD CONSTRAINT fk_rails_2258e947c4 FOREIGN KEY (workflow_accrual_job_id) REFERENCES workflow_accrual_jobs(id);


--
-- Name: fk_rails_23d6ecdef7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_notes
    ADD CONSTRAINT fk_rails_23d6ecdef7 FOREIGN KEY (file_format_id) REFERENCES file_formats(id);


--
-- Name: fk_rails_242362ff14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY archived_accrual_jobs
    ADD CONSTRAINT fk_rails_242362ff14 FOREIGN KEY (cfs_directory_id) REFERENCES cfs_directories(id);


--
-- Name: fk_rails_2c4d650843; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_tests_file_format_test_reasons_joins
    ADD CONSTRAINT fk_rails_2c4d650843 FOREIGN KEY (file_format_test_reason_id) REFERENCES file_format_test_reasons(id);


--
-- Name: fk_rails_3c52875c13; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_virtual_repository_joins
    ADD CONSTRAINT fk_rails_3c52875c13 FOREIGN KEY (virtual_repository_id) REFERENCES virtual_repositories(id);


--
-- Name: fk_rails_4f056ac37d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_profiles_file_extensions_joins
    ADD CONSTRAINT fk_rails_4f056ac37d FOREIGN KEY (file_format_profile_id) REFERENCES file_format_profiles(id);


--
-- Name: fk_rails_607f94da7e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_files
    ADD CONSTRAINT fk_rails_607f94da7e FOREIGN KEY (workflow_accrual_job_id) REFERENCES workflow_accrual_jobs(id);


--
-- Name: fk_rails_62dc01f91f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY archived_accrual_jobs
    ADD CONSTRAINT fk_rails_62dc01f91f FOREIGN KEY (file_group_id) REFERENCES file_groups(id);


--
-- Name: fk_rails_64a0ab5e2a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_profiles_content_types_joins
    ADD CONSTRAINT fk_rails_64a0ab5e2a FOREIGN KEY (content_type_id) REFERENCES content_types(id);


--
-- Name: fk_rails_65d86c9570; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_directories
    ADD CONSTRAINT fk_rails_65d86c9570 FOREIGN KEY (workflow_accrual_job_id) REFERENCES workflow_accrual_jobs(id);


--
-- Name: fk_rails_714fa9a746; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_jobs
    ADD CONSTRAINT fk_rails_714fa9a746 FOREIGN KEY (cfs_directory_id) REFERENCES cfs_directories(id);


--
-- Name: fk_rails_7a05f7a57b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_virtual_repository_joins
    ADD CONSTRAINT fk_rails_7a05f7a57b FOREIGN KEY (collection_id) REFERENCES collections(id);


--
-- Name: fk_rails_7bca99061f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_profiles_content_types_joins
    ADD CONSTRAINT fk_rails_7bca99061f FOREIGN KEY (file_format_profile_id) REFERENCES file_format_profiles(id);


--
-- Name: fk_rails_7fe769aa60; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_item_bulk_imports
    ADD CONSTRAINT fk_rails_7fe769aa60 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_89fc58d755; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fits_content_type_batches
    ADD CONSTRAINT fk_rails_89fc58d755 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_8aaf1a7eb8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_comments
    ADD CONSTRAINT fk_rails_8aaf1a7eb8 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_8c3cd8e21a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_tests
    ADD CONSTRAINT fk_rails_8c3cd8e21a FOREIGN KEY (cfs_file_id) REFERENCES cfs_files(id);


--
-- Name: fk_rails_96a254d3f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_conflicts
    ADD CONSTRAINT fk_rails_96a254d3f1 FOREIGN KEY (workflow_accrual_job_id) REFERENCES workflow_accrual_jobs(id);


--
-- Name: fk_rails_9a724fc755; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_notes
    ADD CONSTRAINT fk_rails_9a724fc755 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_9fe508decd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_jobs
    ADD CONSTRAINT fk_rails_9fe508decd FOREIGN KEY (amazon_backup_id) REFERENCES amazon_backups(id);


--
-- Name: fk_rails_ac902747ea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_item_bulk_imports
    ADD CONSTRAINT fk_rails_ac902747ea FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_rails_ad920efa96; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fits_file_extension_batches
    ADD CONSTRAINT fk_rails_ad920efa96 FOREIGN KEY (file_extension_id) REFERENCES file_extensions(id);


--
-- Name: fk_rails_b46749d78d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fits_file_extension_batches
    ADD CONSTRAINT fk_rails_b46749d78d FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_c986487b1e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_tests
    ADD CONSTRAINT fk_rails_c986487b1e FOREIGN KEY (file_format_profile_id) REFERENCES file_format_profiles(id);


--
-- Name: fk_rails_d5e71e625f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_rails_d5e71e625f FOREIGN KEY (collection_id) REFERENCES collections(id);


--
-- Name: fk_rails_d8a84160a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY archived_accrual_jobs
    ADD CONSTRAINT fk_rails_d8a84160a7 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_dbc5e7d3a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fits_content_type_batches
    ADD CONSTRAINT fk_rails_dbc5e7d3a2 FOREIGN KEY (content_type_id) REFERENCES content_types(id);


--
-- Name: fk_rails_e77d7e4911; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_profiles_file_extensions_joins
    ADD CONSTRAINT fk_rails_e77d7e4911 FOREIGN KEY (file_extension_id) REFERENCES file_extensions(id);


--
-- Name: fk_rails_e8d155be25; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cfs_files
    ADD CONSTRAINT fk_rails_e8d155be25 FOREIGN KEY (content_type_id) REFERENCES content_types(id);


--
-- Name: fk_rails_ed83b6871f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cfs_files
    ADD CONSTRAINT fk_rails_ed83b6871f FOREIGN KEY (file_extension_id) REFERENCES file_extensions(id);


--
-- Name: fk_rails_f4de0ef7ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_fixity_checks
    ADD CONSTRAINT fk_rails_f4de0ef7ac FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_f4f83033da; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY file_format_normalization_paths
    ADD CONSTRAINT fk_rails_f4f83033da FOREIGN KEY (file_format_id) REFERENCES file_formats(id);


--
-- Name: fk_rails_f584154b33; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY archived_accrual_jobs
    ADD CONSTRAINT fk_rails_f584154b33 FOREIGN KEY (amazon_backup_id) REFERENCES amazon_backups(id);


--
-- Name: fk_rails_f6abf55b81; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT fk_rails_f6abf55b81 FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: fk_rails_fa4c2c0a3b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workflow_accrual_jobs
    ADD CONSTRAINT fk_rails_fa4c2c0a3b FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_fdd3dd4403; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pronoms
    ADD CONSTRAINT fk_rails_fdd3dd4403 FOREIGN KEY (file_format_id) REFERENCES file_formats(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20120723183454');

INSERT INTO schema_migrations (version) VALUES ('20120723212328');

INSERT INTO schema_migrations (version) VALUES ('20120724205839');

INSERT INTO schema_migrations (version) VALUES ('20120725162036');

INSERT INTO schema_migrations (version) VALUES ('20120725202659');

INSERT INTO schema_migrations (version) VALUES ('20120726164948');

INSERT INTO schema_migrations (version) VALUES ('20120726165438');

INSERT INTO schema_migrations (version) VALUES ('20120726170920');

INSERT INTO schema_migrations (version) VALUES ('20120726210554');

INSERT INTO schema_migrations (version) VALUES ('20120727170444');

INSERT INTO schema_migrations (version) VALUES ('20120727190840');

INSERT INTO schema_migrations (version) VALUES ('20120727205022');

INSERT INTO schema_migrations (version) VALUES ('20120727211800');

INSERT INTO schema_migrations (version) VALUES ('20120727212826');

INSERT INTO schema_migrations (version) VALUES ('20120727215843');

INSERT INTO schema_migrations (version) VALUES ('20120727222206');

INSERT INTO schema_migrations (version) VALUES ('20120730190034');

INSERT INTO schema_migrations (version) VALUES ('20120730204420');

INSERT INTO schema_migrations (version) VALUES ('20120731172956');

INSERT INTO schema_migrations (version) VALUES ('20120731174612');

INSERT INTO schema_migrations (version) VALUES ('20120731195332');

INSERT INTO schema_migrations (version) VALUES ('20120731200900');

INSERT INTO schema_migrations (version) VALUES ('20120731222552');

INSERT INTO schema_migrations (version) VALUES ('20120801141451');

INSERT INTO schema_migrations (version) VALUES ('20120801193922');

INSERT INTO schema_migrations (version) VALUES ('20120822151305');

INSERT INTO schema_migrations (version) VALUES ('20120822153335');

INSERT INTO schema_migrations (version) VALUES ('20120823200906');

INSERT INTO schema_migrations (version) VALUES ('20120823204310');

INSERT INTO schema_migrations (version) VALUES ('20120828182138');

INSERT INTO schema_migrations (version) VALUES ('20120829153644');

INSERT INTO schema_migrations (version) VALUES ('20120830210252');

INSERT INTO schema_migrations (version) VALUES ('20120910150517');

INSERT INTO schema_migrations (version) VALUES ('20120910151633');

INSERT INTO schema_migrations (version) VALUES ('20120910153521');

INSERT INTO schema_migrations (version) VALUES ('20120910162212');

INSERT INTO schema_migrations (version) VALUES ('20120917195429');

INSERT INTO schema_migrations (version) VALUES ('20120918181620');

INSERT INTO schema_migrations (version) VALUES ('20120925175714');

INSERT INTO schema_migrations (version) VALUES ('20120925175758');

INSERT INTO schema_migrations (version) VALUES ('20120925214848');

INSERT INTO schema_migrations (version) VALUES ('20120925221448');

INSERT INTO schema_migrations (version) VALUES ('20120928195102');

INSERT INTO schema_migrations (version) VALUES ('20121004210537');

INSERT INTO schema_migrations (version) VALUES ('20121008164346');

INSERT INTO schema_migrations (version) VALUES ('20121024154347');

INSERT INTO schema_migrations (version) VALUES ('20121106182743');

INSERT INTO schema_migrations (version) VALUES ('20121107205541');

INSERT INTO schema_migrations (version) VALUES ('20121108180509');

INSERT INTO schema_migrations (version) VALUES ('20121219211723');

INSERT INTO schema_migrations (version) VALUES ('20121219211931');

INSERT INTO schema_migrations (version) VALUES ('20130125155156');

INSERT INTO schema_migrations (version) VALUES ('20130211181738');

INSERT INTO schema_migrations (version) VALUES ('20130211222200');

INSERT INTO schema_migrations (version) VALUES ('20130212212413');

INSERT INTO schema_migrations (version) VALUES ('20130213152311');

INSERT INTO schema_migrations (version) VALUES ('20130213162526');

INSERT INTO schema_migrations (version) VALUES ('20130214170800');

INSERT INTO schema_migrations (version) VALUES ('20130301165908');

INSERT INTO schema_migrations (version) VALUES ('20130304190239');

INSERT INTO schema_migrations (version) VALUES ('20130307181108');

INSERT INTO schema_migrations (version) VALUES ('20130311162054');

INSERT INTO schema_migrations (version) VALUES ('20130327212251');

INSERT INTO schema_migrations (version) VALUES ('20130328185811');

INSERT INTO schema_migrations (version) VALUES ('20130408151257');

INSERT INTO schema_migrations (version) VALUES ('20130408223729');

INSERT INTO schema_migrations (version) VALUES ('20130424222640');

INSERT INTO schema_migrations (version) VALUES ('20130426145321');

INSERT INTO schema_migrations (version) VALUES ('20130426151142');

INSERT INTO schema_migrations (version) VALUES ('20130430184832');

INSERT INTO schema_migrations (version) VALUES ('20130501022611');

INSERT INTO schema_migrations (version) VALUES ('20130516182122');

INSERT INTO schema_migrations (version) VALUES ('20130523204024');

INSERT INTO schema_migrations (version) VALUES ('20130524143202');

INSERT INTO schema_migrations (version) VALUES ('20130528151355');

INSERT INTO schema_migrations (version) VALUES ('20130528152210');

INSERT INTO schema_migrations (version) VALUES ('20130531164842');

INSERT INTO schema_migrations (version) VALUES ('20130531172551');

INSERT INTO schema_migrations (version) VALUES ('20130531180926');

INSERT INTO schema_migrations (version) VALUES ('20130610171240');

INSERT INTO schema_migrations (version) VALUES ('20130620162758');

INSERT INTO schema_migrations (version) VALUES ('20130628204524');

INSERT INTO schema_migrations (version) VALUES ('20130628204724');

INSERT INTO schema_migrations (version) VALUES ('20130628204922');

INSERT INTO schema_migrations (version) VALUES ('20130912165653');

INSERT INTO schema_migrations (version) VALUES ('20130912190139');

INSERT INTO schema_migrations (version) VALUES ('20130930173250');

INSERT INTO schema_migrations (version) VALUES ('20140123184422');

INSERT INTO schema_migrations (version) VALUES ('20140130171207');

INSERT INTO schema_migrations (version) VALUES ('20140206194153');

INSERT INTO schema_migrations (version) VALUES ('20140206195254');

INSERT INTO schema_migrations (version) VALUES ('20140306174156');

INSERT INTO schema_migrations (version) VALUES ('20140306220612');

INSERT INTO schema_migrations (version) VALUES ('20140311195100');

INSERT INTO schema_migrations (version) VALUES ('20140311195745');

INSERT INTO schema_migrations (version) VALUES ('20140311211633');

INSERT INTO schema_migrations (version) VALUES ('20140312143243');

INSERT INTO schema_migrations (version) VALUES ('20140313224433');

INSERT INTO schema_migrations (version) VALUES ('20140318193810');

INSERT INTO schema_migrations (version) VALUES ('20140318193904');

INSERT INTO schema_migrations (version) VALUES ('20140325160348');

INSERT INTO schema_migrations (version) VALUES ('20140325161140');

INSERT INTO schema_migrations (version) VALUES ('20140331185904');

INSERT INTO schema_migrations (version) VALUES ('20140331190400');

INSERT INTO schema_migrations (version) VALUES ('20140424210638');

INSERT INTO schema_migrations (version) VALUES ('20140517143007');

INSERT INTO schema_migrations (version) VALUES ('20140527175510');

INSERT INTO schema_migrations (version) VALUES ('20140527190504');

INSERT INTO schema_migrations (version) VALUES ('20140613165040');

INSERT INTO schema_migrations (version) VALUES ('20140708200003');

INSERT INTO schema_migrations (version) VALUES ('20140708220726');

INSERT INTO schema_migrations (version) VALUES ('20140708223302');

INSERT INTO schema_migrations (version) VALUES ('20140709153705');

INSERT INTO schema_migrations (version) VALUES ('20140730195513');

INSERT INTO schema_migrations (version) VALUES ('20140731213225');

INSERT INTO schema_migrations (version) VALUES ('20140801204239');

INSERT INTO schema_migrations (version) VALUES ('20140821180028');

INSERT INTO schema_migrations (version) VALUES ('20140821185728');

INSERT INTO schema_migrations (version) VALUES ('20140919195200');

INSERT INTO schema_migrations (version) VALUES ('20140919211418');

INSERT INTO schema_migrations (version) VALUES ('20141002155435');

INSERT INTO schema_migrations (version) VALUES ('20141002155446');

INSERT INTO schema_migrations (version) VALUES ('20141006163154');

INSERT INTO schema_migrations (version) VALUES ('20141007204736');

INSERT INTO schema_migrations (version) VALUES ('20141008134937');

INSERT INTO schema_migrations (version) VALUES ('20141008213501');

INSERT INTO schema_migrations (version) VALUES ('20141009210118');

INSERT INTO schema_migrations (version) VALUES ('20141010214341');

INSERT INTO schema_migrations (version) VALUES ('20141111171712');

INSERT INTO schema_migrations (version) VALUES ('20141111220854');

INSERT INTO schema_migrations (version) VALUES ('20141117192815');

INSERT INTO schema_migrations (version) VALUES ('20141119223036');

INSERT INTO schema_migrations (version) VALUES ('20141119230908');

INSERT INTO schema_migrations (version) VALUES ('20141124221217');

INSERT INTO schema_migrations (version) VALUES ('20141124221933');

INSERT INTO schema_migrations (version) VALUES ('20141202170603');

INSERT INTO schema_migrations (version) VALUES ('20141204165919');

INSERT INTO schema_migrations (version) VALUES ('20141208215312');

INSERT INTO schema_migrations (version) VALUES ('20141217152139');

INSERT INTO schema_migrations (version) VALUES ('20141217155120');

INSERT INTO schema_migrations (version) VALUES ('20141219200334');

INSERT INTO schema_migrations (version) VALUES ('20141222162152');

INSERT INTO schema_migrations (version) VALUES ('20141223214209');

INSERT INTO schema_migrations (version) VALUES ('20141229194747');

INSERT INTO schema_migrations (version) VALUES ('20150107151851');

INSERT INTO schema_migrations (version) VALUES ('20150115200721');

INSERT INTO schema_migrations (version) VALUES ('20150120180909');

INSERT INTO schema_migrations (version) VALUES ('20150120182658');

INSERT INTO schema_migrations (version) VALUES ('20150120221842');

INSERT INTO schema_migrations (version) VALUES ('20150126153758');

INSERT INTO schema_migrations (version) VALUES ('20150128191608');

INSERT INTO schema_migrations (version) VALUES ('20150128231416');

INSERT INTO schema_migrations (version) VALUES ('20150129163528');

INSERT INTO schema_migrations (version) VALUES ('20150129163558');

INSERT INTO schema_migrations (version) VALUES ('20150129164513');

INSERT INTO schema_migrations (version) VALUES ('20150129212630');

INSERT INTO schema_migrations (version) VALUES ('20150129225137');

INSERT INTO schema_migrations (version) VALUES ('20150129225153');

INSERT INTO schema_migrations (version) VALUES ('20150210220335');

INSERT INTO schema_migrations (version) VALUES ('20150210220730');

INSERT INTO schema_migrations (version) VALUES ('20150217225223');

INSERT INTO schema_migrations (version) VALUES ('20150424212432');

INSERT INTO schema_migrations (version) VALUES ('20150424212501');

INSERT INTO schema_migrations (version) VALUES ('20150507193408');

INSERT INTO schema_migrations (version) VALUES ('20150507193716');

INSERT INTO schema_migrations (version) VALUES ('20150507193738');

INSERT INTO schema_migrations (version) VALUES ('20150508191123');

INSERT INTO schema_migrations (version) VALUES ('20150521173040');

INSERT INTO schema_migrations (version) VALUES ('20150529171424');

INSERT INTO schema_migrations (version) VALUES ('20150617154451');

INSERT INTO schema_migrations (version) VALUES ('20150908195139');

INSERT INTO schema_migrations (version) VALUES ('20150916152553');

INSERT INTO schema_migrations (version) VALUES ('20150917221307');

INSERT INTO schema_migrations (version) VALUES ('20150918191709');

INSERT INTO schema_migrations (version) VALUES ('20150928151036');

INSERT INTO schema_migrations (version) VALUES ('20150928171015');

INSERT INTO schema_migrations (version) VALUES ('20151006191119');

INSERT INTO schema_migrations (version) VALUES ('20151006210709');

INSERT INTO schema_migrations (version) VALUES ('20151007154809');

INSERT INTO schema_migrations (version) VALUES ('20151008152822');

INSERT INTO schema_migrations (version) VALUES ('20151008210801');

INSERT INTO schema_migrations (version) VALUES ('20151008224057');

INSERT INTO schema_migrations (version) VALUES ('20151008224141');

INSERT INTO schema_migrations (version) VALUES ('20151009180849');

INSERT INTO schema_migrations (version) VALUES ('20151013195837');

INSERT INTO schema_migrations (version) VALUES ('20151014151423');

INSERT INTO schema_migrations (version) VALUES ('20151019141222');

INSERT INTO schema_migrations (version) VALUES ('20151030190201');

INSERT INTO schema_migrations (version) VALUES ('20151030192656');

INSERT INTO schema_migrations (version) VALUES ('20151104182843');

INSERT INTO schema_migrations (version) VALUES ('20151104210143');

INSERT INTO schema_migrations (version) VALUES ('20151112160558');

INSERT INTO schema_migrations (version) VALUES ('20151201192336');

INSERT INTO schema_migrations (version) VALUES ('20151202172013');

INSERT INTO schema_migrations (version) VALUES ('20151203164731');

INSERT INTO schema_migrations (version) VALUES ('20151214190747');

INSERT INTO schema_migrations (version) VALUES ('20151214224916');

INSERT INTO schema_migrations (version) VALUES ('20151215152708');

INSERT INTO schema_migrations (version) VALUES ('20160126233249');

INSERT INTO schema_migrations (version) VALUES ('20160202183505');

INSERT INTO schema_migrations (version) VALUES ('20160302185450');

INSERT INTO schema_migrations (version) VALUES ('20160302191209');

INSERT INTO schema_migrations (version) VALUES ('20160302195237');

INSERT INTO schema_migrations (version) VALUES ('20160322151332');

INSERT INTO schema_migrations (version) VALUES ('20160330152020');

INSERT INTO schema_migrations (version) VALUES ('20160401193220');

INSERT INTO schema_migrations (version) VALUES ('20160411215028');

INSERT INTO schema_migrations (version) VALUES ('20160419143152');

INSERT INTO schema_migrations (version) VALUES ('20160419150545');

INSERT INTO schema_migrations (version) VALUES ('20160504200651');

INSERT INTO schema_migrations (version) VALUES ('20160504204653');

INSERT INTO schema_migrations (version) VALUES ('20160505011200');

INSERT INTO schema_migrations (version) VALUES ('20160518182728');

INSERT INTO schema_migrations (version) VALUES ('20160531161759');

INSERT INTO schema_migrations (version) VALUES ('20160531162831');

INSERT INTO schema_migrations (version) VALUES ('20160610185704');

INSERT INTO schema_migrations (version) VALUES ('20160610220337');

INSERT INTO schema_migrations (version) VALUES ('20160621144247');

INSERT INTO schema_migrations (version) VALUES ('20160805144959');

INSERT INTO schema_migrations (version) VALUES ('20160805172916');

INSERT INTO schema_migrations (version) VALUES ('20160805193842');

INSERT INTO schema_migrations (version) VALUES ('20160805200045');

INSERT INTO schema_migrations (version) VALUES ('20160815185511');

INSERT INTO schema_migrations (version) VALUES ('20160819153537');

INSERT INTO schema_migrations (version) VALUES ('20160824143252');

INSERT INTO schema_migrations (version) VALUES ('20160825144956');

