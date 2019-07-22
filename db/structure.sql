SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: access_system_collection_joins_touch_access_system(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.access_system_collection_joins_touch_access_system() RETURNS trigger
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

CREATE FUNCTION public.access_system_collection_joins_touch_collection() RETURNS trigger
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
-- Name: assessments_touch_storage_medium(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.assessments_touch_storage_medium() RETURNS trigger
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

CREATE FUNCTION public.cfs_dir_update_bit_level_file_group() RETURNS trigger
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

CREATE FUNCTION public.cfs_dir_update_cfs_dir() RETURNS trigger
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
-- Name: cfs_directory_relative_path(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cfs_directory_relative_path(integer) RETURNS text
    LANGUAGE sql
    AS $_$

SELECT CASE WHEN (SELECT parent_type
                  FROM cfs_directories
                  WHERE id = $1) = 'FileGroup'

  THEN

    (SELECT path
     FROM cfs_directories
     WHERE id = $1)

       ELSE

         (SELECT concat(cfs_directory_relative_path(parent_id), '/', path)
          FROM cfs_directories
          WHERE id = $1)

       END

$_$;


--
-- Name: cfs_file_relative_path(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cfs_file_relative_path(integer) RETURNS text
    LANGUAGE sql
    AS $_$

SELECT concat(cfs_directory_relative_path(cfs_directory_id), '/', name)
FROM cfs_files
WHERE id = $1;

$_$;


--
-- Name: cfs_file_update_cfs_directory_and_extension_and_content_type(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cfs_file_update_cfs_directory_and_extension_and_content_type() RETURNS trigger
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

CREATE FUNCTION public.cfs_files_touch_cfs_directory() RETURNS trigger
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

CREATE FUNCTION public.cfs_files_touch_content_type() RETURNS trigger
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

CREATE FUNCTION public.cfs_files_touch_file_extension() RETURNS trigger
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
-- Name: collections_touch_repository(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.collections_touch_repository() RETURNS trigger
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
-- Name: create_timeline_stats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_timeline_stats() RETURNS void
    LANGUAGE sql
    AS $$
  DROP TABLE IF EXISTS timeline_stats;
  CREATE TABLE timeline_stats AS
    SELECT month, count(*) AS count, coalesce(sum(size), 0) AS size FROM
      (SELECT id, date_trunc('month', created_at) AS month, size FROM cfs_files) AS S
    GROUP BY month;
$$;


--
-- Name: file_group_content_type_report(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.file_group_content_type_report(file_group_id integer, start integer, count integer) RETURNS TABLE(cfs_file_id integer, content_type_name character varying, cfs_file_relative_path character varying, uuid character varying)
    LANGUAGE sql
    AS $_$
SELECT
  V.cfs_file_id,
  CT.name,
  cfs_file_relative_path(F.id),
  U.uuid
FROM view_cfs_files_to_parents V,
  cfs_files F,
  content_types CT,
  medusa_uuids U
WHERE V.file_group_id = $1
      AND V.cfs_file_id = F.id
      AND F.content_type_id = CT.id
      AND F.id = U.uuidable_id
      AND U.uuidable_type = 'CfsFile'
ORDER BY F.id
LIMIT $3
OFFSET $2
$_$;


--
-- Name: file_groups_touch_collection(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.file_groups_touch_collection() RETURNS trigger
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
-- Name: file_groups_touch_producer(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.file_groups_touch_producer() RETURNS trigger
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

CREATE FUNCTION public.job_cfs_directory_exports_touch_cfs_directory() RETURNS trigger
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

CREATE FUNCTION public.job_cfs_directory_exports_touch_user() RETURNS trigger
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

CREATE FUNCTION public.job_cfs_initial_file_group_assessments_touch_file_group() RETURNS trigger
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

CREATE FUNCTION public.job_fits_directories_touch_cfs_directory() RETURNS trigger
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

CREATE FUNCTION public.job_fits_directories_touch_file_group() RETURNS trigger
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

CREATE FUNCTION public.job_fits_directory_trees_touch_cfs_directory() RETURNS trigger
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

CREATE FUNCTION public.job_fits_directory_trees_touch_file_group() RETURNS trigger
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

CREATE FUNCTION public.job_ingest_staging_deletes_touch_external_file_group() RETURNS trigger
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

CREATE FUNCTION public.job_ingest_staging_deletes_touch_user() RETURNS trigger
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

CREATE FUNCTION public.job_virus_scans_touch_file_group() RETURNS trigger
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

CREATE FUNCTION public.projects_touch_collection() RETURNS trigger
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

CREATE FUNCTION public.related_file_group_joins_touch_source_file_group() RETURNS trigger
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

CREATE FUNCTION public.related_file_group_joins_touch_target_file_group() RETURNS trigger
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

CREATE FUNCTION public.repositories_touch_institution() RETURNS trigger
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

CREATE FUNCTION public.resource_typeable_resource_type_joins_touch_resource_type() RETURNS trigger
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
-- Name: update_cache_content_type_stats_by_collection(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cache_content_type_stats_by_collection() RETURNS void
    LANGUAGE sql
    AS $$
    DELETE FROM cache_content_type_stats_by_collection;
    INSERT INTO cache_content_type_stats_by_collection (collection_id, content_type_id, name, file_count, file_size)
      (SELECT collection_id, content_type_id, name, file_count, file_size FROM view_file_content_type_stats_by_collection);
$$;


--
-- Name: update_cache_file_extension_stats_by_collection(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_cache_file_extension_stats_by_collection() RETURNS void
    LANGUAGE sql
    AS $$
    DELETE FROM cache_file_extension_stats_by_collection;
    INSERT INTO cache_file_extension_stats_by_collection (collection_id, file_extension_id, extension, file_count, file_size)
      (SELECT collection_id, file_extension_id, extension, file_count, file_size FROM view_file_extension_stats_by_collection);
$$;


--
-- Name: virus_scans_touch_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.virus_scans_touch_file_group() RETURNS trigger
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

CREATE FUNCTION public.workflow_accrual_comments_touch_workflow_accrual_job() RETURNS trigger
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

CREATE FUNCTION public.workflow_accrual_conflicts_touch_workflow_accrual_job() RETURNS trigger
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

CREATE FUNCTION public.workflow_accrual_directories_touch_workflow_accrual_job() RETURNS trigger
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

CREATE FUNCTION public.workflow_accrual_files_touch_workflow_accrual_job() RETURNS trigger
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
-- Name: workflow_accrual_jobs_touch_cfs_directory(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.workflow_accrual_jobs_touch_cfs_directory() RETURNS trigger
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

CREATE FUNCTION public.workflow_accrual_jobs_touch_user() RETURNS trigger
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
-- Name: workflow_ingests_touch_bit_level_file_group(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.workflow_ingests_touch_bit_level_file_group() RETURNS trigger
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

CREATE FUNCTION public.workflow_ingests_touch_external_file_group() RETURNS trigger
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

CREATE FUNCTION public.workflow_ingests_touch_user() RETURNS trigger
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

CREATE TABLE public.access_system_collection_joins (
    id integer NOT NULL,
    access_system_id integer,
    collection_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: access_system_collection_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.access_system_collection_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_system_collection_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.access_system_collection_joins_id_seq OWNED BY public.access_system_collection_joins.id;


--
-- Name: access_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.access_systems (
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

CREATE SEQUENCE public.access_systems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_systems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.access_systems_id_seq OWNED BY public.access_systems.id;


--
-- Name: amqp_accrual_delete_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.amqp_accrual_delete_jobs (
    id integer NOT NULL,
    client character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    incoming_message text
);


--
-- Name: amqp_accrual_delete_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.amqp_accrual_delete_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: amqp_accrual_delete_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.amqp_accrual_delete_jobs_id_seq OWNED BY public.amqp_accrual_delete_jobs.id;


--
-- Name: amqp_accrual_ingest_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.amqp_accrual_ingest_jobs (
    id integer NOT NULL,
    client character varying NOT NULL,
    uuid character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    incoming_message text,
    target_key character varying,
    copied boolean DEFAULT false
);


--
-- Name: amqp_accrual_ingest_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.amqp_accrual_ingest_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: amqp_accrual_ingest_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.amqp_accrual_ingest_jobs_id_seq OWNED BY public.amqp_accrual_ingest_jobs.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: archived_accrual_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.archived_accrual_jobs (
    id integer NOT NULL,
    report text,
    file_group_id integer,
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

CREATE SEQUENCE public.archived_accrual_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: archived_accrual_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.archived_accrual_jobs_id_seq OWNED BY public.archived_accrual_jobs.id;


--
-- Name: assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessments (
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

CREATE SEQUENCE public.assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assessments_id_seq OWNED BY public.assessments.id;


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attachments (
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

CREATE SEQUENCE public.attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attachments_id_seq OWNED BY public.attachments.id;


--
-- Name: cache_content_type_stats_by_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_content_type_stats_by_collection (
    collection_id integer,
    content_type_id integer,
    name character varying,
    file_count integer,
    file_size numeric
);


--
-- Name: cache_file_extension_stats_by_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_file_extension_stats_by_collection (
    collection_id integer,
    file_extension_id integer,
    extension character varying,
    file_count integer,
    file_size numeric
);


--
-- Name: cascaded_event_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cascaded_event_joins (
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

CREATE SEQUENCE public.cascaded_event_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cascaded_event_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cascaded_event_joins_id_seq OWNED BY public.cascaded_event_joins.id;


--
-- Name: cascaded_red_flag_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cascaded_red_flag_joins (
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

CREATE SEQUENCE public.cascaded_red_flag_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cascaded_red_flag_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cascaded_red_flag_joins_id_seq OWNED BY public.cascaded_red_flag_joins.id;


--
-- Name: cfs_directories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cfs_directories (
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

CREATE SEQUENCE public.cfs_directories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cfs_directories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cfs_directories_id_seq OWNED BY public.cfs_directories.id;


--
-- Name: cfs_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cfs_files (
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

CREATE SEQUENCE public.cfs_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cfs_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cfs_files_id_seq OWNED BY public.cfs_files.id;


--
-- Name: file_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_groups (
    id integer NOT NULL,
    external_file_location character varying(255),
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
    access_url character varying,
    acquisition_method character varying,
    collection_uuid character varying
);


--
-- Name: cfs_files_to_file_groups; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.cfs_files_to_file_groups AS
 SELECT f.id AS cfs_file_id,
    fg.id AS file_group_id
   FROM public.cfs_files f,
    public.cfs_directories d,
    public.cfs_directories rd,
    public.file_groups fg
  WHERE ((f.cfs_directory_id = d.id) AND (d.root_cfs_directory_id = rd.id) AND (rd.parent_id = fg.id));


--
-- Name: collection_virtual_repository_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_virtual_repository_joins (
    id integer NOT NULL,
    collection_id integer,
    virtual_repository_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: collection_virtual_repository_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collection_virtual_repository_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_virtual_repository_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collection_virtual_repository_joins_id_seq OWNED BY public.collection_virtual_repository_joins.id;


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collections (
    id integer NOT NULL,
    repository_id integer,
    title character varying(255),
    description text,
    access_url character varying(255),
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    contact_id integer,
    private_description text,
    notes_html text,
    description_html text,
    private_description_html text,
    external_id character varying(255),
    publish boolean DEFAULT false,
    representative_image character varying DEFAULT ''::character varying,
    representative_item character varying DEFAULT ''::character varying,
    physical_collection_url character varying
);


--
-- Name: collections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collections_id_seq OWNED BY public.collections.id;


--
-- Name: content_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_types (
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

CREATE SEQUENCE public.content_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_types_id_seq OWNED BY public.content_types.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
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

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: downloader_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.downloader_requests (
    id integer NOT NULL,
    email character varying,
    downloader_id character varying,
    status character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parameters text
);


--
-- Name: downloader_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.downloader_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloader_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.downloader_requests_id_seq OWNED BY public.downloader_requests.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
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

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: file_extensions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_extensions (
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

CREATE SEQUENCE public.file_extensions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_extensions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_extensions_id_seq OWNED BY public.file_extensions.id;


--
-- Name: file_format_normalization_paths; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_format_normalization_paths (
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
    notes text,
    input_logical_extension_id integer,
    output_logical_extension_id integer
);


--
-- Name: file_format_normalization_paths_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_format_normalization_paths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_normalization_paths_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_format_normalization_paths_id_seq OWNED BY public.file_format_normalization_paths.id;


--
-- Name: file_format_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_format_notes (
    id integer NOT NULL,
    file_format_id integer,
    user_id integer,
    date date NOT NULL,
    note text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    note_html text
);


--
-- Name: file_format_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_format_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_format_notes_id_seq OWNED BY public.file_format_notes.id;


--
-- Name: file_format_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_format_profiles (
    id integer NOT NULL,
    name character varying NOT NULL,
    software character varying,
    software_version character varying,
    os_environment character varying,
    os_version character varying,
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status character varying DEFAULT 'active'::character varying NOT NULL
);


--
-- Name: file_format_profiles_content_types_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_format_profiles_content_types_joins (
    id integer NOT NULL,
    file_format_profile_id integer,
    content_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: file_format_profiles_content_types_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_format_profiles_content_types_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_profiles_content_types_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_format_profiles_content_types_joins_id_seq OWNED BY public.file_format_profiles_content_types_joins.id;


--
-- Name: file_format_profiles_file_extensions_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_format_profiles_file_extensions_joins (
    id integer NOT NULL,
    file_format_profile_id integer,
    file_extension_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: file_format_profiles_file_extensions_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_format_profiles_file_extensions_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_profiles_file_extensions_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_format_profiles_file_extensions_joins_id_seq OWNED BY public.file_format_profiles_file_extensions_joins.id;


--
-- Name: file_format_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_format_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_format_profiles_id_seq OWNED BY public.file_format_profiles.id;


--
-- Name: file_format_test_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_format_test_reasons (
    id integer NOT NULL,
    label character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: file_format_test_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_format_test_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_test_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_format_test_reasons_id_seq OWNED BY public.file_format_test_reasons.id;


--
-- Name: file_format_tests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_format_tests (
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

CREATE TABLE public.file_format_tests_file_format_test_reasons_joins (
    id integer NOT NULL,
    file_format_test_id integer,
    file_format_test_reason_id integer
);


--
-- Name: file_format_tests_file_format_test_reasons_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_format_tests_file_format_test_reasons_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_tests_file_format_test_reasons_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_format_tests_file_format_test_reasons_joins_id_seq OWNED BY public.file_format_tests_file_format_test_reasons_joins.id;


--
-- Name: file_format_tests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_format_tests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_format_tests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_format_tests_id_seq OWNED BY public.file_format_tests.id;


--
-- Name: file_formats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_formats (
    id integer NOT NULL,
    name character varying NOT NULL,
    policy_summary text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: file_formats_file_format_profiles_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_formats_file_format_profiles_joins (
    id bigint NOT NULL,
    file_format_id bigint,
    file_format_profile_id bigint
);


--
-- Name: file_formats_file_format_profiles_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_formats_file_format_profiles_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_formats_file_format_profiles_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_formats_file_format_profiles_joins_id_seq OWNED BY public.file_formats_file_format_profiles_joins.id;


--
-- Name: file_formats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_formats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_formats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_formats_id_seq OWNED BY public.file_formats.id;


--
-- Name: file_formats_logical_extensions_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_formats_logical_extensions_joins (
    id bigint NOT NULL,
    file_format_id bigint,
    logical_extension_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "position" integer
);


--
-- Name: file_formats_logical_extensions_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_formats_logical_extensions_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_formats_logical_extensions_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_formats_logical_extensions_joins_id_seq OWNED BY public.file_formats_logical_extensions_joins.id;


--
-- Name: file_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_groups_id_seq OWNED BY public.file_groups.id;


--
-- Name: fits_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fits_data (
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

CREATE SEQUENCE public.fits_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fits_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fits_data_id_seq OWNED BY public.fits_data.id;


--
-- Name: fixity_check_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fixity_check_results (
    id bigint NOT NULL,
    cfs_file_id bigint,
    status integer NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: fixity_check_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fixity_check_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fixity_check_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fixity_check_results_id_seq OWNED BY public.fixity_check_results.id;


--
-- Name: institutions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.institutions (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: institutions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.institutions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: institutions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.institutions_id_seq OWNED BY public.institutions.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.items (
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
    source_media character varying,
    ingested boolean DEFAULT false,
    cfs_directory_id integer
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: job_cfs_directory_export_cleanups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_cfs_directory_export_cleanups (
    id integer NOT NULL,
    directory character varying(255)
);


--
-- Name: job_cfs_directory_export_cleanups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_cfs_directory_export_cleanups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_cfs_directory_export_cleanups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_cfs_directory_export_cleanups_id_seq OWNED BY public.job_cfs_directory_export_cleanups.id;


--
-- Name: job_cfs_directory_exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_cfs_directory_exports (
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

CREATE SEQUENCE public.job_cfs_directory_exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_cfs_directory_exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_cfs_directory_exports_id_seq OWNED BY public.job_cfs_directory_exports.id;


--
-- Name: job_cfs_initial_directory_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_cfs_initial_directory_assessments (
    id integer NOT NULL,
    file_group_id integer,
    cfs_directory_id integer,
    file_count integer
);


--
-- Name: job_cfs_initial_directory_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_cfs_initial_directory_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_cfs_initial_directory_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_cfs_initial_directory_assessments_id_seq OWNED BY public.job_cfs_initial_directory_assessments.id;


--
-- Name: job_cfs_initial_file_group_assessments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_cfs_initial_file_group_assessments (
    id integer NOT NULL,
    file_group_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: job_cfs_initial_file_group_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_cfs_initial_file_group_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_cfs_initial_file_group_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_cfs_initial_file_group_assessments_id_seq OWNED BY public.job_cfs_initial_file_group_assessments.id;


--
-- Name: job_fits_content_type_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_fits_content_type_batches (
    id integer NOT NULL,
    user_id integer,
    content_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_fits_content_type_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_fits_content_type_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_fits_content_type_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_fits_content_type_batches_id_seq OWNED BY public.job_fits_content_type_batches.id;


--
-- Name: job_fits_directories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_fits_directories (
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

CREATE SEQUENCE public.job_fits_directories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_fits_directories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_fits_directories_id_seq OWNED BY public.job_fits_directories.id;


--
-- Name: job_fits_directory_trees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_fits_directory_trees (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cfs_directory_id integer,
    file_group_id integer
);


--
-- Name: job_fits_directory_trees_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_fits_directory_trees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_fits_directory_trees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_fits_directory_trees_id_seq OWNED BY public.job_fits_directory_trees.id;


--
-- Name: job_fits_file_extension_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_fits_file_extension_batches (
    id integer NOT NULL,
    user_id integer,
    file_extension_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_fits_file_extension_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_fits_file_extension_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_fits_file_extension_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_fits_file_extension_batches_id_seq OWNED BY public.job_fits_file_extension_batches.id;


--
-- Name: job_fixity_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_fixity_checks (
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

CREATE SEQUENCE public.job_fixity_checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_fixity_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_fixity_checks_id_seq OWNED BY public.job_fixity_checks.id;


--
-- Name: job_ingest_staging_deletes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_ingest_staging_deletes (
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

CREATE SEQUENCE public.job_ingest_staging_deletes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_ingest_staging_deletes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_ingest_staging_deletes_id_seq OWNED BY public.job_ingest_staging_deletes.id;


--
-- Name: job_item_bulk_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_item_bulk_imports (
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

CREATE SEQUENCE public.job_item_bulk_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_item_bulk_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_item_bulk_imports_id_seq OWNED BY public.job_item_bulk_imports.id;


--
-- Name: job_report_cfs_directory_manifests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_report_cfs_directory_manifests (
    id bigint NOT NULL,
    user_id bigint,
    cfs_directory_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_report_cfs_directory_manifests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_report_cfs_directory_manifests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_report_cfs_directory_manifests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_report_cfs_directory_manifests_id_seq OWNED BY public.job_report_cfs_directory_manifests.id;


--
-- Name: job_report_cfs_directory_maps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_report_cfs_directory_maps (
    id bigint NOT NULL,
    user_id bigint,
    cfs_directory_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_report_cfs_directory_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_report_cfs_directory_maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_report_cfs_directory_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_report_cfs_directory_maps_id_seq OWNED BY public.job_report_cfs_directory_maps.id;


--
-- Name: job_report_producers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_report_producers (
    id bigint NOT NULL,
    user_id bigint,
    producer_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_report_producers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_report_producers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_report_producers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_report_producers_id_seq OWNED BY public.job_report_producers.id;


--
-- Name: job_sunspot_reindices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_sunspot_reindices (
    id bigint NOT NULL,
    start_id integer,
    end_id integer,
    batch_size integer,
    class_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_sunspot_reindices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_sunspot_reindices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_sunspot_reindices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_sunspot_reindices_id_seq OWNED BY public.job_sunspot_reindices.id;


--
-- Name: job_virus_scans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_virus_scans (
    id integer NOT NULL,
    file_group_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_virus_scans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_virus_scans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_virus_scans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_virus_scans_id_seq OWNED BY public.job_virus_scans.id;


--
-- Name: logical_extensions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logical_extensions (
    id bigint NOT NULL,
    extension character varying,
    description character varying DEFAULT ''::character varying
);


--
-- Name: logical_extensions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.logical_extensions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logical_extensions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.logical_extensions_id_seq OWNED BY public.logical_extensions.id;


--
-- Name: medusa_uuids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.medusa_uuids (
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

CREATE SEQUENCE public.medusa_uuids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: medusa_uuids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.medusa_uuids_id_seq OWNED BY public.medusa_uuids.id;


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repositories (
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
-- Name: orphaned_events; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.orphaned_events AS
 SELECT e.id
   FROM (public.events e
     LEFT JOIN public.cfs_files evt ON ((e.eventable_id = evt.id)))
  WHERE (((e.eventable_type)::text = 'CfsFile'::text) AND (evt.id IS NULL))
UNION
 SELECT e.id
   FROM (public.events e
     LEFT JOIN public.cfs_directories evt ON ((e.eventable_id = evt.id)))
  WHERE (((e.eventable_type)::text = 'CfsDirectory'::text) AND (evt.id IS NULL))
UNION
 SELECT e.id
   FROM (public.events e
     LEFT JOIN public.file_groups evt ON ((e.eventable_id = evt.id)))
  WHERE (((e.eventable_type)::text = 'FileGroup'::text) AND (evt.id IS NULL))
UNION
 SELECT e.id
   FROM (public.events e
     LEFT JOIN public.collections evt ON ((e.eventable_id = evt.id)))
  WHERE (((e.eventable_type)::text = 'Collection'::text) AND (evt.id IS NULL))
UNION
 SELECT e.id
   FROM (public.events e
     LEFT JOIN public.repositories evt ON ((e.eventable_id = evt.id)))
  WHERE (((e.eventable_type)::text = 'Repository'::text) AND (evt.id IS NULL));


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.people (
    id integer NOT NULL,
    email character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.people_id_seq OWNED BY public.people.id;


--
-- Name: producers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.producers (
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

CREATE SEQUENCE public.production_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: production_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.production_units_id_seq OWNED BY public.producers.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
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
    external_id character varying DEFAULT ''::character varying,
    ingest_folder character varying,
    destination_folder_uuid character varying,
    summary_html text,
    specifications_html text,
    collection_uuid character varying
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: pronoms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pronoms (
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

CREATE SEQUENCE public.pronoms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pronoms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pronoms_id_seq OWNED BY public.pronoms.id;


--
-- Name: red_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.red_flags (
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

CREATE SEQUENCE public.red_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: red_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.red_flags_id_seq OWNED BY public.red_flags.id;


--
-- Name: related_file_format_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.related_file_format_joins (
    id bigint NOT NULL,
    file_format_id bigint,
    related_file_format_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: related_file_format_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.related_file_format_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: related_file_format_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.related_file_format_joins_id_seq OWNED BY public.related_file_format_joins.id;


--
-- Name: related_file_group_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.related_file_group_joins (
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

CREATE SEQUENCE public.related_file_group_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: related_file_group_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.related_file_group_joins_id_seq OWNED BY public.related_file_group_joins.id;


--
-- Name: repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repositories_id_seq OWNED BY public.repositories.id;


--
-- Name: resource_typeable_resource_type_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_typeable_resource_type_joins (
    id integer NOT NULL,
    resource_typeable_id integer,
    resource_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    resource_typeable_type character varying
);


--
-- Name: resource_typeable_resource_type_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resource_typeable_resource_type_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_typeable_resource_type_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resource_typeable_resource_type_joins_id_seq OWNED BY public.resource_typeable_resource_type_joins.id;


--
-- Name: resource_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resource_types (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: resource_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.resource_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resource_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.resource_types_id_seq OWNED BY public.resource_types.id;


--
-- Name: rights_declarations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rights_declarations (
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

CREATE SEQUENCE public.rights_declarations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rights_declarations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rights_declarations_id_seq OWNED BY public.rights_declarations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: static_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.static_pages (
    id integer NOT NULL,
    key character varying,
    page_text text DEFAULT ''::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: static_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.static_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: static_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.static_pages_id_seq OWNED BY public.static_pages.id;


--
-- Name: storage_media; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.storage_media (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: storage_media_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.storage_media_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: storage_media_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.storage_media_id_seq OWNED BY public.storage_media.id;


--
-- Name: subcollection_joins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subcollection_joins (
    id integer NOT NULL,
    parent_collection_id integer NOT NULL,
    child_collection_id integer NOT NULL
);


--
-- Name: subcollection_joins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subcollection_joins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subcollection_joins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subcollection_joins_id_seq OWNED BY public.subcollection_joins.id;


--
-- Name: timeline_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timeline_stats (
    month timestamp without time zone,
    count bigint,
    size numeric
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    uid character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    email character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: view_bit_level_file_group_cfs_root_stats_two_ways; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_bit_level_file_group_cfs_root_stats_two_ways AS
 SELECT fg.id AS file_group_id,
    round((fg.total_file_size * (1073741824)::numeric)) AS file_group_size,
    fg.total_files AS file_group_count,
    d.id AS cfs_directory_id,
    d.tree_size AS cfs_directory_size,
    d.tree_count AS cfs_directory_count
   FROM (public.file_groups fg
     LEFT JOIN public.cfs_directories d ON ((fg.id = d.parent_id)))
  WHERE ((d.parent_type)::text = 'FileGroup'::text);


--
-- Name: view_cfs_directories_file_stats_two_ways; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_cfs_directories_file_stats_two_ways AS
 SELECT d.id,
    d.tree_count,
    d.tree_size,
    (( SELECT count(*) AS count
           FROM public.cfs_files f
          WHERE (f.cfs_directory_id = d.id)) + ( SELECT sum(COALESCE(sd.tree_count, 0)) AS sum
           FROM public.cfs_directories sd
          WHERE (((sd.parent_type)::text = 'CfsDirectory'::text) AND (sd.parent_id = d.id)))) AS computed_count,
    (( SELECT sum(COALESCE(f.size, (0)::numeric)) AS sum
           FROM public.cfs_files f
          WHERE (f.cfs_directory_id = d.id)) + ( SELECT sum(COALESCE(sd.tree_size, (0)::numeric)) AS sum
           FROM public.cfs_directories sd
          WHERE (((sd.parent_type)::text = 'CfsDirectory'::text) AND (sd.parent_id = d.id)))) AS computed_size
   FROM public.cfs_directories d;


--
-- Name: view_cfs_directories_inconsistent_file_stats; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_cfs_directories_inconsistent_file_stats AS
 SELECT view_cfs_directories_file_stats_two_ways.id,
    view_cfs_directories_file_stats_two_ways.tree_count,
    view_cfs_directories_file_stats_two_ways.tree_size,
    view_cfs_directories_file_stats_two_ways.computed_count,
    view_cfs_directories_file_stats_two_ways.computed_size
   FROM public.view_cfs_directories_file_stats_two_ways
  WHERE ((view_cfs_directories_file_stats_two_ways.tree_count <> view_cfs_directories_file_stats_two_ways.computed_count) OR (view_cfs_directories_file_stats_two_ways.tree_size <> view_cfs_directories_file_stats_two_ways.computed_size));


--
-- Name: view_cfs_files_to_parents; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_cfs_files_to_parents AS
 SELECT f.id AS cfs_file_id,
    d.id AS cfs_directory_id,
    rd.id AS root_cfs_directory_id,
    fg.id AS file_group_id,
    c.id AS collection_id,
    r.id AS repository_id,
    r.institution_id
   FROM public.cfs_files f,
    public.cfs_directories d,
    public.cfs_directories rd,
    public.file_groups fg,
    public.collections c,
    public.repositories r
  WHERE ((f.cfs_directory_id = d.id) AND (d.root_cfs_directory_id = rd.id) AND (rd.parent_id = fg.id) AND (fg.collection_id = c.id) AND (c.repository_id = r.id));


--
-- Name: view_cfs_files_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_cfs_files_summary AS
 SELECT f.md5_sum,
    v.cfs_file_id,
    v.cfs_directory_id,
    v.file_group_id,
    v.collection_id,
    v.repository_id,
    u.uuid,
    f.name,
    public.cfs_file_relative_path(f.id) AS relative_path,
    c.name AS content_type,
    f.mtime,
    f.size
   FROM public.view_cfs_files_to_parents v,
    public.cfs_files f,
    public.medusa_uuids u,
    public.content_types c
  WHERE ((f.id = v.cfs_file_id) AND ((u.uuidable_type)::text = 'CfsFile'::text) AND (u.uuidable_id = f.id) AND (f.content_type_id = c.id));


--
-- Name: view_file_content_type_stats_by_collection; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_file_content_type_stats_by_collection AS
 SELECT v.collection_id,
    ct.id AS content_type_id,
    ct.name,
    count(*) AS file_count,
    COALESCE(sum(COALESCE(f.size, (0)::numeric))) AS file_size
   FROM public.cfs_files f,
    public.view_cfs_files_to_parents v,
    public.content_types ct
  WHERE ((f.id = v.cfs_file_id) AND (f.content_type_id = ct.id))
  GROUP BY v.collection_id, ct.id, ct.name;


--
-- Name: view_file_content_type_stats_by_repository; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_file_content_type_stats_by_repository AS
 SELECT ct.id AS content_type_id,
    ct.name,
    p.repository_id,
    COALESCE(sum(COALESCE(f.size, (0)::numeric)), (0)::numeric) AS file_size,
    count(f.id) AS file_count
   FROM ((public.content_types ct
     JOIN public.cfs_files f ON ((ct.id = f.content_type_id)))
     JOIN public.view_cfs_files_to_parents p ON ((f.id = p.cfs_file_id)))
  GROUP BY ct.id, ct.name, p.repository_id
  ORDER BY ct.name;


--
-- Name: view_file_extension_stats_by_collection; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_file_extension_stats_by_collection AS
 SELECT v.collection_id,
    fe.id AS file_extension_id,
    fe.extension,
    count(*) AS file_count,
    COALESCE(sum(COALESCE(f.size, (0)::numeric))) AS file_size
   FROM public.cfs_files f,
    public.view_cfs_files_to_parents v,
    public.file_extensions fe
  WHERE ((f.id = v.cfs_file_id) AND (f.file_extension_id = fe.id))
  GROUP BY v.collection_id, fe.id, fe.extension;


--
-- Name: view_file_extension_stats_by_repository; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_file_extension_stats_by_repository AS
 SELECT fe.id AS file_extension_id,
    fe.extension,
    p.repository_id,
    COALESCE(sum(COALESCE(f.size, (0)::numeric)), (0)::numeric) AS file_size,
    count(f.id) AS file_count
   FROM ((public.file_extensions fe
     JOIN public.cfs_files f ON ((fe.id = f.file_extension_id)))
     JOIN public.view_cfs_files_to_parents p ON ((f.id = p.cfs_file_id)))
  GROUP BY fe.id, fe.extension, p.repository_id
  ORDER BY fe.extension;


--
-- Name: view_file_group_dashboard_info; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_file_group_dashboard_info AS
 SELECT fg.id,
    fg.title,
    fg.total_files,
    fg.total_file_size,
    c.id AS collection_id,
    c.title AS collection_title,
    r.id AS repository_id,
    r.title AS repository_title,
    c.external_id AS collection_external_id
   FROM public.file_groups fg,
    public.collections c,
    public.repositories r,
    public.cfs_directories cfs
  WHERE (((fg.type)::text = 'BitLevelFileGroup'::text) AND (fg.collection_id = c.id) AND (c.repository_id = r.id) AND ((cfs.parent_type)::text = 'FileGroup'::text) AND (cfs.parent_id = fg.id))
  ORDER BY fg.id;


--
-- Name: view_md5_duplicates; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_md5_duplicates AS
 SELECT v.md5_sum,
    v.cfs_file_id,
    v.cfs_directory_id,
    v.file_group_id,
    v.collection_id,
    v.repository_id,
    v.uuid,
    v.name,
    v.relative_path,
    v.content_type,
    v.mtime,
    v.size
   FROM public.view_cfs_files_summary v
  WHERE ((v.md5_sum)::text IN ( SELECT duplicates.md5_sum
           FROM ( SELECT cfs_files.md5_sum,
                    count(*) AS count
                   FROM public.cfs_files
                  GROUP BY cfs_files.md5_sum
                 HAVING (count(*) > 1)) duplicates));


--
-- Name: view_tested_file_relations; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_tested_file_relations AS
 SELECT fft.id AS file_format_test_id,
    f.id AS cfs_file_id,
    f.content_type_id,
    f.file_extension_id,
    p.repository_id,
    p.collection_id
   FROM ((public.file_format_tests fft
     JOIN public.cfs_files f ON ((fft.cfs_file_id = f.id)))
     JOIN public.view_cfs_files_to_parents p ON ((f.id = p.cfs_file_id)));


--
-- Name: view_tested_file_content_type_counts; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_tested_file_content_type_counts AS
 SELECT view_tested_file_relations.content_type_id,
    view_tested_file_relations.repository_id,
    count(*) AS count
   FROM public.view_tested_file_relations
  GROUP BY view_tested_file_relations.content_type_id, view_tested_file_relations.repository_id;


--
-- Name: view_tested_file_content_type_counts_by_collection; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_tested_file_content_type_counts_by_collection AS
 SELECT view_tested_file_relations.content_type_id,
    view_tested_file_relations.collection_id,
    count(*) AS count
   FROM public.view_tested_file_relations
  GROUP BY view_tested_file_relations.content_type_id, view_tested_file_relations.collection_id;


--
-- Name: view_tested_file_file_extension_counts; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_tested_file_file_extension_counts AS
 SELECT view_tested_file_relations.file_extension_id,
    view_tested_file_relations.repository_id,
    count(*) AS count
   FROM public.view_tested_file_relations
  GROUP BY view_tested_file_relations.file_extension_id, view_tested_file_relations.repository_id;


--
-- Name: view_tested_file_file_extension_counts_by_collection; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_tested_file_file_extension_counts_by_collection AS
 SELECT view_tested_file_relations.file_extension_id,
    view_tested_file_relations.collection_id,
    count(*) AS count
   FROM public.view_tested_file_relations
  GROUP BY view_tested_file_relations.file_extension_id, view_tested_file_relations.collection_id;


--
-- Name: view_tested_file_stats; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_tested_file_stats AS
 SELECT f.id,
    f.content_type_id,
    f.file_extension_id,
    p.repository_id
   FROM ((public.file_format_tests fft
     JOIN public.cfs_files f ON ((fft.cfs_file_id = f.id)))
     JOIN public.view_cfs_files_to_parents p ON ((f.id = p.cfs_file_id)))
 LIMIT 10;


--
-- Name: virtual_repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.virtual_repositories (
    id integer NOT NULL,
    title character varying,
    repository_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: virtual_repositories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.virtual_repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: virtual_repositories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.virtual_repositories_id_seq OWNED BY public.virtual_repositories.id;


--
-- Name: virus_scans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.virus_scans (
    id integer NOT NULL,
    file_group_id integer,
    scan_result text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: virus_scans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.virus_scans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: virus_scans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.virus_scans_id_seq OWNED BY public.virus_scans.id;


--
-- Name: workflow_accrual_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_accrual_comments (
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

CREATE SEQUENCE public.workflow_accrual_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_accrual_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workflow_accrual_comments_id_seq OWNED BY public.workflow_accrual_comments.id;


--
-- Name: workflow_accrual_conflicts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_accrual_conflicts (
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

CREATE SEQUENCE public.workflow_accrual_conflicts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_accrual_conflicts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workflow_accrual_conflicts_id_seq OWNED BY public.workflow_accrual_conflicts.id;


--
-- Name: workflow_accrual_directories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_accrual_directories (
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

CREATE SEQUENCE public.workflow_accrual_directories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_accrual_directories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workflow_accrual_directories_id_seq OWNED BY public.workflow_accrual_directories.id;


--
-- Name: workflow_accrual_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_accrual_files (
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

CREATE SEQUENCE public.workflow_accrual_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_accrual_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workflow_accrual_files_id_seq OWNED BY public.workflow_accrual_files.id;


--
-- Name: workflow_accrual_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_accrual_jobs (
    id integer NOT NULL,
    cfs_directory_id integer,
    staging_path text,
    state character varying,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    allow_overwrite boolean DEFAULT false,
    empty_file_report text DEFAULT ''::text,
    copy_start_time timestamp without time zone,
    assessment_start_time timestamp without time zone
);


--
-- Name: workflow_accrual_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workflow_accrual_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_accrual_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workflow_accrual_jobs_id_seq OWNED BY public.workflow_accrual_jobs.id;


--
-- Name: workflow_accrual_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_accrual_keys (
    id bigint NOT NULL,
    key text,
    workflow_accrual_job_id bigint,
    error text,
    copy_requested boolean DEFAULT false
);


--
-- Name: workflow_accrual_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workflow_accrual_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_accrual_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workflow_accrual_keys_id_seq OWNED BY public.workflow_accrual_keys.id;


--
-- Name: workflow_file_group_deletes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_file_group_deletes (
    id integer NOT NULL,
    requester_id integer,
    approver_id integer,
    file_group_id integer,
    state character varying,
    requester_reason text,
    approver_reason text,
    cached_file_group_title character varying,
    cached_collection_id integer,
    cached_cfs_directory_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    cached_collection_uuid character varying
);


--
-- Name: workflow_file_group_deletes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workflow_file_group_deletes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_file_group_deletes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workflow_file_group_deletes_id_seq OWNED BY public.workflow_file_group_deletes.id;


--
-- Name: workflow_ingests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_ingests (
    id integer NOT NULL,
    state character varying(255),
    external_file_group_id integer,
    bit_level_file_group_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: workflow_ingests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workflow_ingests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_ingests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workflow_ingests_id_seq OWNED BY public.workflow_ingests.id;


--
-- Name: workflow_item_ingest_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_item_ingest_requests (
    id integer NOT NULL,
    workflow_project_item_ingest_id integer,
    item_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: workflow_item_ingest_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workflow_item_ingest_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_item_ingest_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workflow_item_ingest_requests_id_seq OWNED BY public.workflow_item_ingest_requests.id;


--
-- Name: workflow_project_item_ingests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workflow_project_item_ingests (
    id integer NOT NULL,
    state character varying NOT NULL,
    project_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: workflow_project_item_ingests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workflow_project_item_ingests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workflow_project_item_ingests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workflow_project_item_ingests_id_seq OWNED BY public.workflow_project_item_ingests.id;


--
-- Name: access_system_collection_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_system_collection_joins ALTER COLUMN id SET DEFAULT nextval('public.access_system_collection_joins_id_seq'::regclass);


--
-- Name: access_systems id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_systems ALTER COLUMN id SET DEFAULT nextval('public.access_systems_id_seq'::regclass);


--
-- Name: amqp_accrual_delete_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amqp_accrual_delete_jobs ALTER COLUMN id SET DEFAULT nextval('public.amqp_accrual_delete_jobs_id_seq'::regclass);


--
-- Name: amqp_accrual_ingest_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amqp_accrual_ingest_jobs ALTER COLUMN id SET DEFAULT nextval('public.amqp_accrual_ingest_jobs_id_seq'::regclass);


--
-- Name: archived_accrual_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archived_accrual_jobs ALTER COLUMN id SET DEFAULT nextval('public.archived_accrual_jobs_id_seq'::regclass);


--
-- Name: assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments ALTER COLUMN id SET DEFAULT nextval('public.assessments_id_seq'::regclass);


--
-- Name: attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments ALTER COLUMN id SET DEFAULT nextval('public.attachments_id_seq'::regclass);


--
-- Name: cascaded_event_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cascaded_event_joins ALTER COLUMN id SET DEFAULT nextval('public.cascaded_event_joins_id_seq'::regclass);


--
-- Name: cascaded_red_flag_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cascaded_red_flag_joins ALTER COLUMN id SET DEFAULT nextval('public.cascaded_red_flag_joins_id_seq'::regclass);


--
-- Name: cfs_directories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfs_directories ALTER COLUMN id SET DEFAULT nextval('public.cfs_directories_id_seq'::regclass);


--
-- Name: cfs_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfs_files ALTER COLUMN id SET DEFAULT nextval('public.cfs_files_id_seq'::regclass);


--
-- Name: collection_virtual_repository_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_virtual_repository_joins ALTER COLUMN id SET DEFAULT nextval('public.collection_virtual_repository_joins_id_seq'::regclass);


--
-- Name: collections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections ALTER COLUMN id SET DEFAULT nextval('public.collections_id_seq'::regclass);


--
-- Name: content_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_types ALTER COLUMN id SET DEFAULT nextval('public.content_types_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: downloader_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.downloader_requests ALTER COLUMN id SET DEFAULT nextval('public.downloader_requests_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: file_extensions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_extensions ALTER COLUMN id SET DEFAULT nextval('public.file_extensions_id_seq'::regclass);


--
-- Name: file_format_normalization_paths id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_normalization_paths ALTER COLUMN id SET DEFAULT nextval('public.file_format_normalization_paths_id_seq'::regclass);


--
-- Name: file_format_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_notes ALTER COLUMN id SET DEFAULT nextval('public.file_format_notes_id_seq'::regclass);


--
-- Name: file_format_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_profiles ALTER COLUMN id SET DEFAULT nextval('public.file_format_profiles_id_seq'::regclass);


--
-- Name: file_format_profiles_content_types_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_profiles_content_types_joins ALTER COLUMN id SET DEFAULT nextval('public.file_format_profiles_content_types_joins_id_seq'::regclass);


--
-- Name: file_format_profiles_file_extensions_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_profiles_file_extensions_joins ALTER COLUMN id SET DEFAULT nextval('public.file_format_profiles_file_extensions_joins_id_seq'::regclass);


--
-- Name: file_format_test_reasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_test_reasons ALTER COLUMN id SET DEFAULT nextval('public.file_format_test_reasons_id_seq'::regclass);


--
-- Name: file_format_tests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_tests ALTER COLUMN id SET DEFAULT nextval('public.file_format_tests_id_seq'::regclass);


--
-- Name: file_format_tests_file_format_test_reasons_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_tests_file_format_test_reasons_joins ALTER COLUMN id SET DEFAULT nextval('public.file_format_tests_file_format_test_reasons_joins_id_seq'::regclass);


--
-- Name: file_formats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_formats ALTER COLUMN id SET DEFAULT nextval('public.file_formats_id_seq'::regclass);


--
-- Name: file_formats_file_format_profiles_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_formats_file_format_profiles_joins ALTER COLUMN id SET DEFAULT nextval('public.file_formats_file_format_profiles_joins_id_seq'::regclass);


--
-- Name: file_formats_logical_extensions_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_formats_logical_extensions_joins ALTER COLUMN id SET DEFAULT nextval('public.file_formats_logical_extensions_joins_id_seq'::regclass);


--
-- Name: file_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_groups ALTER COLUMN id SET DEFAULT nextval('public.file_groups_id_seq'::regclass);


--
-- Name: fits_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fits_data ALTER COLUMN id SET DEFAULT nextval('public.fits_data_id_seq'::regclass);


--
-- Name: fixity_check_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fixity_check_results ALTER COLUMN id SET DEFAULT nextval('public.fixity_check_results_id_seq'::regclass);


--
-- Name: institutions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.institutions ALTER COLUMN id SET DEFAULT nextval('public.institutions_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Name: job_cfs_directory_export_cleanups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_cfs_directory_export_cleanups ALTER COLUMN id SET DEFAULT nextval('public.job_cfs_directory_export_cleanups_id_seq'::regclass);


--
-- Name: job_cfs_directory_exports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_cfs_directory_exports ALTER COLUMN id SET DEFAULT nextval('public.job_cfs_directory_exports_id_seq'::regclass);


--
-- Name: job_cfs_initial_directory_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_cfs_initial_directory_assessments ALTER COLUMN id SET DEFAULT nextval('public.job_cfs_initial_directory_assessments_id_seq'::regclass);


--
-- Name: job_cfs_initial_file_group_assessments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_cfs_initial_file_group_assessments ALTER COLUMN id SET DEFAULT nextval('public.job_cfs_initial_file_group_assessments_id_seq'::regclass);


--
-- Name: job_fits_content_type_batches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fits_content_type_batches ALTER COLUMN id SET DEFAULT nextval('public.job_fits_content_type_batches_id_seq'::regclass);


--
-- Name: job_fits_directories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fits_directories ALTER COLUMN id SET DEFAULT nextval('public.job_fits_directories_id_seq'::regclass);


--
-- Name: job_fits_directory_trees id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fits_directory_trees ALTER COLUMN id SET DEFAULT nextval('public.job_fits_directory_trees_id_seq'::regclass);


--
-- Name: job_fits_file_extension_batches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fits_file_extension_batches ALTER COLUMN id SET DEFAULT nextval('public.job_fits_file_extension_batches_id_seq'::regclass);


--
-- Name: job_fixity_checks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fixity_checks ALTER COLUMN id SET DEFAULT nextval('public.job_fixity_checks_id_seq'::regclass);


--
-- Name: job_ingest_staging_deletes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_ingest_staging_deletes ALTER COLUMN id SET DEFAULT nextval('public.job_ingest_staging_deletes_id_seq'::regclass);


--
-- Name: job_item_bulk_imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_item_bulk_imports ALTER COLUMN id SET DEFAULT nextval('public.job_item_bulk_imports_id_seq'::regclass);


--
-- Name: job_report_cfs_directory_manifests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_report_cfs_directory_manifests ALTER COLUMN id SET DEFAULT nextval('public.job_report_cfs_directory_manifests_id_seq'::regclass);


--
-- Name: job_report_cfs_directory_maps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_report_cfs_directory_maps ALTER COLUMN id SET DEFAULT nextval('public.job_report_cfs_directory_maps_id_seq'::regclass);


--
-- Name: job_report_producers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_report_producers ALTER COLUMN id SET DEFAULT nextval('public.job_report_producers_id_seq'::regclass);


--
-- Name: job_sunspot_reindices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_sunspot_reindices ALTER COLUMN id SET DEFAULT nextval('public.job_sunspot_reindices_id_seq'::regclass);


--
-- Name: job_virus_scans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_virus_scans ALTER COLUMN id SET DEFAULT nextval('public.job_virus_scans_id_seq'::regclass);


--
-- Name: logical_extensions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logical_extensions ALTER COLUMN id SET DEFAULT nextval('public.logical_extensions_id_seq'::regclass);


--
-- Name: medusa_uuids id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medusa_uuids ALTER COLUMN id SET DEFAULT nextval('public.medusa_uuids_id_seq'::regclass);


--
-- Name: people id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people ALTER COLUMN id SET DEFAULT nextval('public.people_id_seq'::regclass);


--
-- Name: producers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.producers ALTER COLUMN id SET DEFAULT nextval('public.production_units_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: pronoms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pronoms ALTER COLUMN id SET DEFAULT nextval('public.pronoms_id_seq'::regclass);


--
-- Name: red_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.red_flags ALTER COLUMN id SET DEFAULT nextval('public.red_flags_id_seq'::regclass);


--
-- Name: related_file_format_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.related_file_format_joins ALTER COLUMN id SET DEFAULT nextval('public.related_file_format_joins_id_seq'::regclass);


--
-- Name: related_file_group_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.related_file_group_joins ALTER COLUMN id SET DEFAULT nextval('public.related_file_group_joins_id_seq'::regclass);


--
-- Name: repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories ALTER COLUMN id SET DEFAULT nextval('public.repositories_id_seq'::regclass);


--
-- Name: resource_typeable_resource_type_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_typeable_resource_type_joins ALTER COLUMN id SET DEFAULT nextval('public.resource_typeable_resource_type_joins_id_seq'::regclass);


--
-- Name: resource_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_types ALTER COLUMN id SET DEFAULT nextval('public.resource_types_id_seq'::regclass);


--
-- Name: rights_declarations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rights_declarations ALTER COLUMN id SET DEFAULT nextval('public.rights_declarations_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: static_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_pages ALTER COLUMN id SET DEFAULT nextval('public.static_pages_id_seq'::regclass);


--
-- Name: storage_media id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_media ALTER COLUMN id SET DEFAULT nextval('public.storage_media_id_seq'::regclass);


--
-- Name: subcollection_joins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcollection_joins ALTER COLUMN id SET DEFAULT nextval('public.subcollection_joins_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: virtual_repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.virtual_repositories ALTER COLUMN id SET DEFAULT nextval('public.virtual_repositories_id_seq'::regclass);


--
-- Name: virus_scans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.virus_scans ALTER COLUMN id SET DEFAULT nextval('public.virus_scans_id_seq'::regclass);


--
-- Name: workflow_accrual_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_comments ALTER COLUMN id SET DEFAULT nextval('public.workflow_accrual_comments_id_seq'::regclass);


--
-- Name: workflow_accrual_conflicts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_conflicts ALTER COLUMN id SET DEFAULT nextval('public.workflow_accrual_conflicts_id_seq'::regclass);


--
-- Name: workflow_accrual_directories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_directories ALTER COLUMN id SET DEFAULT nextval('public.workflow_accrual_directories_id_seq'::regclass);


--
-- Name: workflow_accrual_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_files ALTER COLUMN id SET DEFAULT nextval('public.workflow_accrual_files_id_seq'::regclass);


--
-- Name: workflow_accrual_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_jobs ALTER COLUMN id SET DEFAULT nextval('public.workflow_accrual_jobs_id_seq'::regclass);


--
-- Name: workflow_accrual_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_keys ALTER COLUMN id SET DEFAULT nextval('public.workflow_accrual_keys_id_seq'::regclass);


--
-- Name: workflow_file_group_deletes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_file_group_deletes ALTER COLUMN id SET DEFAULT nextval('public.workflow_file_group_deletes_id_seq'::regclass);


--
-- Name: workflow_ingests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_ingests ALTER COLUMN id SET DEFAULT nextval('public.workflow_ingests_id_seq'::regclass);


--
-- Name: workflow_item_ingest_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_item_ingest_requests ALTER COLUMN id SET DEFAULT nextval('public.workflow_item_ingest_requests_id_seq'::regclass);


--
-- Name: workflow_project_item_ingests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_project_item_ingests ALTER COLUMN id SET DEFAULT nextval('public.workflow_project_item_ingests_id_seq'::regclass);


--
-- Name: access_system_collection_joins access_system_collection_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_system_collection_joins
    ADD CONSTRAINT access_system_collection_joins_pkey PRIMARY KEY (id);


--
-- Name: access_systems access_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_systems
    ADD CONSTRAINT access_systems_pkey PRIMARY KEY (id);


--
-- Name: amqp_accrual_delete_jobs amqp_accrual_delete_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amqp_accrual_delete_jobs
    ADD CONSTRAINT amqp_accrual_delete_jobs_pkey PRIMARY KEY (id);


--
-- Name: amqp_accrual_ingest_jobs amqp_accrual_ingest_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amqp_accrual_ingest_jobs
    ADD CONSTRAINT amqp_accrual_ingest_jobs_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: archived_accrual_jobs archived_accrual_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archived_accrual_jobs
    ADD CONSTRAINT archived_accrual_jobs_pkey PRIMARY KEY (id);


--
-- Name: assessments assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_pkey PRIMARY KEY (id);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: cascaded_event_joins cascaded_event_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cascaded_event_joins
    ADD CONSTRAINT cascaded_event_joins_pkey PRIMARY KEY (id);


--
-- Name: cascaded_red_flag_joins cascaded_red_flag_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cascaded_red_flag_joins
    ADD CONSTRAINT cascaded_red_flag_joins_pkey PRIMARY KEY (id);


--
-- Name: cfs_directories cfs_directories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfs_directories
    ADD CONSTRAINT cfs_directories_pkey PRIMARY KEY (id);


--
-- Name: cfs_files cfs_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfs_files
    ADD CONSTRAINT cfs_files_pkey PRIMARY KEY (id);


--
-- Name: collection_virtual_repository_joins collection_virtual_repository_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_virtual_repository_joins
    ADD CONSTRAINT collection_virtual_repository_joins_pkey PRIMARY KEY (id);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: content_types content_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_types
    ADD CONSTRAINT content_types_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: downloader_requests downloader_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.downloader_requests
    ADD CONSTRAINT downloader_requests_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: file_extensions file_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_extensions
    ADD CONSTRAINT file_extensions_pkey PRIMARY KEY (id);


--
-- Name: file_format_normalization_paths file_format_normalization_paths_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_normalization_paths
    ADD CONSTRAINT file_format_normalization_paths_pkey PRIMARY KEY (id);


--
-- Name: file_format_notes file_format_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_notes
    ADD CONSTRAINT file_format_notes_pkey PRIMARY KEY (id);


--
-- Name: file_format_profiles_content_types_joins file_format_profiles_content_types_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_profiles_content_types_joins
    ADD CONSTRAINT file_format_profiles_content_types_joins_pkey PRIMARY KEY (id);


--
-- Name: file_format_profiles_file_extensions_joins file_format_profiles_file_extensions_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_profiles_file_extensions_joins
    ADD CONSTRAINT file_format_profiles_file_extensions_joins_pkey PRIMARY KEY (id);


--
-- Name: file_format_profiles file_format_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_profiles
    ADD CONSTRAINT file_format_profiles_pkey PRIMARY KEY (id);


--
-- Name: file_format_test_reasons file_format_test_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_test_reasons
    ADD CONSTRAINT file_format_test_reasons_pkey PRIMARY KEY (id);


--
-- Name: file_format_tests_file_format_test_reasons_joins file_format_tests_file_format_test_reasons_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_tests_file_format_test_reasons_joins
    ADD CONSTRAINT file_format_tests_file_format_test_reasons_joins_pkey PRIMARY KEY (id);


--
-- Name: file_format_tests file_format_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_tests
    ADD CONSTRAINT file_format_tests_pkey PRIMARY KEY (id);


--
-- Name: file_formats_file_format_profiles_joins file_formats_file_format_profiles_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_formats_file_format_profiles_joins
    ADD CONSTRAINT file_formats_file_format_profiles_joins_pkey PRIMARY KEY (id);


--
-- Name: file_formats_logical_extensions_joins file_formats_logical_extensions_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_formats_logical_extensions_joins
    ADD CONSTRAINT file_formats_logical_extensions_joins_pkey PRIMARY KEY (id);


--
-- Name: file_formats file_formats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_formats
    ADD CONSTRAINT file_formats_pkey PRIMARY KEY (id);


--
-- Name: file_groups file_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_groups
    ADD CONSTRAINT file_groups_pkey PRIMARY KEY (id);


--
-- Name: fits_data fits_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fits_data
    ADD CONSTRAINT fits_data_pkey PRIMARY KEY (id);


--
-- Name: fixity_check_results fixity_check_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fixity_check_results
    ADD CONSTRAINT fixity_check_results_pkey PRIMARY KEY (id);


--
-- Name: institutions institutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.institutions
    ADD CONSTRAINT institutions_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: job_cfs_directory_export_cleanups job_cfs_directory_export_cleanups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_cfs_directory_export_cleanups
    ADD CONSTRAINT job_cfs_directory_export_cleanups_pkey PRIMARY KEY (id);


--
-- Name: job_cfs_directory_exports job_cfs_directory_exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_cfs_directory_exports
    ADD CONSTRAINT job_cfs_directory_exports_pkey PRIMARY KEY (id);


--
-- Name: job_cfs_initial_directory_assessments job_cfs_initial_directory_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_cfs_initial_directory_assessments
    ADD CONSTRAINT job_cfs_initial_directory_assessments_pkey PRIMARY KEY (id);


--
-- Name: job_cfs_initial_file_group_assessments job_cfs_initial_file_group_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_cfs_initial_file_group_assessments
    ADD CONSTRAINT job_cfs_initial_file_group_assessments_pkey PRIMARY KEY (id);


--
-- Name: job_fits_content_type_batches job_fits_content_type_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fits_content_type_batches
    ADD CONSTRAINT job_fits_content_type_batches_pkey PRIMARY KEY (id);


--
-- Name: job_fits_directories job_fits_directories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fits_directories
    ADD CONSTRAINT job_fits_directories_pkey PRIMARY KEY (id);


--
-- Name: job_fits_directory_trees job_fits_directory_trees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fits_directory_trees
    ADD CONSTRAINT job_fits_directory_trees_pkey PRIMARY KEY (id);


--
-- Name: job_fits_file_extension_batches job_fits_file_extension_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fits_file_extension_batches
    ADD CONSTRAINT job_fits_file_extension_batches_pkey PRIMARY KEY (id);


--
-- Name: job_fixity_checks job_fixity_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fixity_checks
    ADD CONSTRAINT job_fixity_checks_pkey PRIMARY KEY (id);


--
-- Name: job_ingest_staging_deletes job_ingest_staging_deletes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_ingest_staging_deletes
    ADD CONSTRAINT job_ingest_staging_deletes_pkey PRIMARY KEY (id);


--
-- Name: job_item_bulk_imports job_item_bulk_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_item_bulk_imports
    ADD CONSTRAINT job_item_bulk_imports_pkey PRIMARY KEY (id);


--
-- Name: job_report_cfs_directory_manifests job_report_cfs_directory_manifests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_report_cfs_directory_manifests
    ADD CONSTRAINT job_report_cfs_directory_manifests_pkey PRIMARY KEY (id);


--
-- Name: job_report_cfs_directory_maps job_report_cfs_directory_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_report_cfs_directory_maps
    ADD CONSTRAINT job_report_cfs_directory_maps_pkey PRIMARY KEY (id);


--
-- Name: job_report_producers job_report_producers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_report_producers
    ADD CONSTRAINT job_report_producers_pkey PRIMARY KEY (id);


--
-- Name: job_sunspot_reindices job_sunspot_reindices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_sunspot_reindices
    ADD CONSTRAINT job_sunspot_reindices_pkey PRIMARY KEY (id);


--
-- Name: job_virus_scans job_virus_scans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_virus_scans
    ADD CONSTRAINT job_virus_scans_pkey PRIMARY KEY (id);


--
-- Name: logical_extensions logical_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logical_extensions
    ADD CONSTRAINT logical_extensions_pkey PRIMARY KEY (id);


--
-- Name: medusa_uuids medusa_uuids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.medusa_uuids
    ADD CONSTRAINT medusa_uuids_pkey PRIMARY KEY (id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: producers production_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.producers
    ADD CONSTRAINT production_units_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: pronoms pronoms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pronoms
    ADD CONSTRAINT pronoms_pkey PRIMARY KEY (id);


--
-- Name: red_flags red_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.red_flags
    ADD CONSTRAINT red_flags_pkey PRIMARY KEY (id);


--
-- Name: related_file_format_joins related_file_format_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.related_file_format_joins
    ADD CONSTRAINT related_file_format_joins_pkey PRIMARY KEY (id);


--
-- Name: related_file_group_joins related_file_group_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.related_file_group_joins
    ADD CONSTRAINT related_file_group_joins_pkey PRIMARY KEY (id);


--
-- Name: repositories repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT repositories_pkey PRIMARY KEY (id);


--
-- Name: resource_typeable_resource_type_joins resource_typeable_resource_type_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_typeable_resource_type_joins
    ADD CONSTRAINT resource_typeable_resource_type_joins_pkey PRIMARY KEY (id);


--
-- Name: resource_types resource_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resource_types
    ADD CONSTRAINT resource_types_pkey PRIMARY KEY (id);


--
-- Name: rights_declarations rights_declarations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rights_declarations
    ADD CONSTRAINT rights_declarations_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: static_pages static_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_pages
    ADD CONSTRAINT static_pages_pkey PRIMARY KEY (id);


--
-- Name: storage_media storage_media_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storage_media
    ADD CONSTRAINT storage_media_pkey PRIMARY KEY (id);


--
-- Name: subcollection_joins subcollection_joins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcollection_joins
    ADD CONSTRAINT subcollection_joins_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: virtual_repositories virtual_repositories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.virtual_repositories
    ADD CONSTRAINT virtual_repositories_pkey PRIMARY KEY (id);


--
-- Name: virus_scans virus_scans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.virus_scans
    ADD CONSTRAINT virus_scans_pkey PRIMARY KEY (id);


--
-- Name: workflow_accrual_comments workflow_accrual_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_comments
    ADD CONSTRAINT workflow_accrual_comments_pkey PRIMARY KEY (id);


--
-- Name: workflow_accrual_conflicts workflow_accrual_conflicts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_conflicts
    ADD CONSTRAINT workflow_accrual_conflicts_pkey PRIMARY KEY (id);


--
-- Name: workflow_accrual_directories workflow_accrual_directories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_directories
    ADD CONSTRAINT workflow_accrual_directories_pkey PRIMARY KEY (id);


--
-- Name: workflow_accrual_files workflow_accrual_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_files
    ADD CONSTRAINT workflow_accrual_files_pkey PRIMARY KEY (id);


--
-- Name: workflow_accrual_jobs workflow_accrual_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_jobs
    ADD CONSTRAINT workflow_accrual_jobs_pkey PRIMARY KEY (id);


--
-- Name: workflow_accrual_keys workflow_accrual_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_keys
    ADD CONSTRAINT workflow_accrual_keys_pkey PRIMARY KEY (id);


--
-- Name: workflow_file_group_deletes workflow_file_group_deletes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_file_group_deletes
    ADD CONSTRAINT workflow_file_group_deletes_pkey PRIMARY KEY (id);


--
-- Name: workflow_ingests workflow_ingests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_ingests
    ADD CONSTRAINT workflow_ingests_pkey PRIMARY KEY (id);


--
-- Name: workflow_item_ingest_requests workflow_item_ingest_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_item_ingest_requests
    ADD CONSTRAINT workflow_item_ingest_requests_pkey PRIMARY KEY (id);


--
-- Name: workflow_project_item_ingests workflow_project_item_ingests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_project_item_ingests
    ADD CONSTRAINT workflow_project_item_ingests_pkey PRIMARY KEY (id);


--
-- Name: cfs_directory_parent_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cfs_directory_parent_idx ON public.cfs_directories USING btree (parent_type, parent_id, path);


--
-- Name: collection_virtual_repository_join_collection_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX collection_virtual_repository_join_collection_index ON public.collection_virtual_repository_joins USING btree (collection_id);


--
-- Name: collection_virtual_repository_join_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX collection_virtual_repository_join_unique_index ON public.collection_virtual_repository_joins USING btree (virtual_repository_id, collection_id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: ffffp_file_format_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ffffp_file_format_idx ON public.file_formats_file_format_profiles_joins USING btree (file_format_id);


--
-- Name: ffffp_file_format_profile_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ffffp_file_format_profile_idx ON public.file_formats_file_format_profiles_joins USING btree (file_format_profile_id);


--
-- Name: fflej_file_format_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fflej_file_format_id_idx ON public.file_formats_logical_extensions_joins USING btree (file_format_id);


--
-- Name: fflej_logical_extension_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fflej_logical_extension_id_idx ON public.file_formats_logical_extensions_joins USING btree (logical_extension_id);


--
-- Name: ffpctj_content_type_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ffpctj_content_type_id_idx ON public.file_format_profiles_content_types_joins USING btree (content_type_id);


--
-- Name: ffpctj_file_format_profile_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ffpctj_file_format_profile_id_idx ON public.file_format_profiles_content_types_joins USING btree (file_format_profile_id);


--
-- Name: ffpfej_file_extension_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ffpfej_file_extension_id_idx ON public.file_format_profiles_file_extensions_joins USING btree (file_extension_id);


--
-- Name: ffpfej_file_format_profile_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ffpfej_file_format_profile_id_idx ON public.file_format_profiles_file_extensions_joins USING btree (file_format_profile_id);


--
-- Name: fft_fftr_joins_fftr_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fft_fftr_joins_fftr_id_index ON public.file_format_tests_file_format_test_reasons_joins USING btree (file_format_test_reason_id);


--
-- Name: fft_fftr_joins_unique_pairs; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX fft_fftr_joins_unique_pairs ON public.file_format_tests_file_format_test_reasons_joins USING btree (file_format_test_id, file_format_test_reason_id);


--
-- Name: fixity_object; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX fixity_object ON public.job_fixity_checks USING btree (fixity_checkable_id, fixity_checkable_type);


--
-- Name: idx_cfs_files_fits_serialized; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cfs_files_fits_serialized ON public.cfs_files USING btree (id) WHERE (NOT fits_serialized);


--
-- Name: idx_cfs_files_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cfs_files_lower_name ON public.cfs_files USING btree (lower((name)::text));


--
-- Name: index_access_system_collection_joins_on_access_system_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_system_collection_joins_on_access_system_id ON public.access_system_collection_joins USING btree (access_system_id);


--
-- Name: index_access_system_collection_joins_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_system_collection_joins_on_collection_id ON public.access_system_collection_joins USING btree (collection_id);


--
-- Name: index_access_system_collection_joins_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_system_collection_joins_on_updated_at ON public.access_system_collection_joins USING btree (updated_at);


--
-- Name: index_access_systems_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_systems_on_updated_at ON public.access_systems USING btree (updated_at);


--
-- Name: index_amqp_accrual_delete_jobs_on_client; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_amqp_accrual_delete_jobs_on_client ON public.amqp_accrual_delete_jobs USING btree (client);


--
-- Name: index_amqp_accrual_ingest_jobs_on_client_and_target_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_amqp_accrual_ingest_jobs_on_client_and_target_key ON public.amqp_accrual_ingest_jobs USING btree (client, target_key);


--
-- Name: index_archived_accrual_jobs_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_archived_accrual_jobs_on_cfs_directory_id ON public.archived_accrual_jobs USING btree (cfs_directory_id);


--
-- Name: index_archived_accrual_jobs_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_archived_accrual_jobs_on_file_group_id ON public.archived_accrual_jobs USING btree (file_group_id);


--
-- Name: index_archived_accrual_jobs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_archived_accrual_jobs_on_user_id ON public.archived_accrual_jobs USING btree (user_id);


--
-- Name: index_assessments_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessments_on_author_id ON public.assessments USING btree (author_id);


--
-- Name: index_assessments_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessments_on_collection_id ON public.assessments USING btree (assessable_id);


--
-- Name: index_assessments_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assessments_on_updated_at ON public.assessments USING btree (updated_at);


--
-- Name: index_attachments_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachments_on_updated_at ON public.attachments USING btree (updated_at);


--
-- Name: index_cache_content_type_stats_by_collection_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cache_content_type_stats_by_collection_on_collection_id ON public.cache_content_type_stats_by_collection USING btree (collection_id);


--
-- Name: index_cache_content_type_stats_by_collection_on_content_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cache_content_type_stats_by_collection_on_content_type_id ON public.cache_content_type_stats_by_collection USING btree (content_type_id);


--
-- Name: index_cache_file_extension_stats_by_collection_fe_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cache_file_extension_stats_by_collection_fe_id ON public.cache_file_extension_stats_by_collection USING btree (file_extension_id);


--
-- Name: index_cache_file_extension_stats_by_collection_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cache_file_extension_stats_by_collection_on_collection_id ON public.cache_file_extension_stats_by_collection USING btree (collection_id);


--
-- Name: index_cascaded_event_joins_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cascaded_event_joins_on_event_id ON public.cascaded_event_joins USING btree (event_id);


--
-- Name: index_cascaded_red_flag_joins_on_red_flag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cascaded_red_flag_joins_on_red_flag_id ON public.cascaded_red_flag_joins USING btree (red_flag_id);


--
-- Name: index_cfs_directories_on_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_directories_on_path ON public.cfs_directories USING btree (path);


--
-- Name: index_cfs_directories_on_root_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_directories_on_root_cfs_directory_id ON public.cfs_directories USING btree (root_cfs_directory_id);


--
-- Name: index_cfs_directories_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_directories_on_updated_at ON public.cfs_directories USING btree (updated_at);


--
-- Name: index_cfs_files_on_cfs_directory_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_cfs_files_on_cfs_directory_id_and_name ON public.cfs_files USING btree (cfs_directory_id, name);


--
-- Name: index_cfs_files_on_content_type_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_content_type_id_and_name ON public.cfs_files USING btree (content_type_id, name);


--
-- Name: index_cfs_files_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_created_at ON public.cfs_files USING btree (created_at);


--
-- Name: index_cfs_files_on_file_extension_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_file_extension_id_and_name ON public.cfs_files USING btree (file_extension_id, name);


--
-- Name: index_cfs_files_on_fixity_check_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_fixity_check_status ON public.cfs_files USING btree (fixity_check_status);


--
-- Name: index_cfs_files_on_fixity_check_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_fixity_check_time ON public.cfs_files USING btree (fixity_check_time);


--
-- Name: index_cfs_files_on_md5_sum; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_md5_sum ON public.cfs_files USING btree (md5_sum);


--
-- Name: index_cfs_files_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_name ON public.cfs_files USING btree (name);


--
-- Name: index_cfs_files_on_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_size ON public.cfs_files USING btree (size);


--
-- Name: index_cfs_files_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cfs_files_on_updated_at ON public.cfs_files USING btree (updated_at);


--
-- Name: index_collections_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_contact_id ON public.collections USING btree (contact_id);


--
-- Name: index_collections_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_external_id ON public.collections USING btree (external_id);


--
-- Name: index_collections_on_publish; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_publish ON public.collections USING btree (publish);


--
-- Name: index_collections_on_repository_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_repository_id ON public.collections USING btree (repository_id);


--
-- Name: index_collections_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collections_on_updated_at ON public.collections USING btree (updated_at);


--
-- Name: index_content_types_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_content_types_on_name ON public.content_types USING btree (name);


--
-- Name: index_downloader_requests_on_downloader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_downloader_requests_on_downloader_id ON public.downloader_requests USING btree (downloader_id);


--
-- Name: index_downloader_requests_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_downloader_requests_on_status ON public.downloader_requests USING btree (status);


--
-- Name: index_events_on_actor_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_actor_email ON public.events USING btree (actor_email);


--
-- Name: index_events_on_cascadable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_cascadable ON public.events USING btree (cascadable);


--
-- Name: index_events_on_eventable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_eventable_id ON public.events USING btree (eventable_id);


--
-- Name: index_events_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_updated_at ON public.events USING btree (updated_at);


--
-- Name: index_file_extensions_on_extension; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_file_extensions_on_extension ON public.file_extensions USING btree (extension);


--
-- Name: index_file_format_normalization_paths_on_file_format_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_format_normalization_paths_on_file_format_id ON public.file_format_normalization_paths USING btree (file_format_id);


--
-- Name: index_file_format_normalization_paths_on_output_format_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_format_normalization_paths_on_output_format_id ON public.file_format_normalization_paths USING btree (output_format_id);


--
-- Name: index_file_format_notes_on_file_format_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_format_notes_on_file_format_id ON public.file_format_notes USING btree (file_format_id);


--
-- Name: index_file_format_notes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_format_notes_on_user_id ON public.file_format_notes USING btree (user_id);


--
-- Name: index_file_format_profiles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_file_format_profiles_on_name ON public.file_format_profiles USING btree (name);


--
-- Name: index_file_format_tests_on_cfs_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_file_format_tests_on_cfs_file_id ON public.file_format_tests USING btree (cfs_file_id);


--
-- Name: index_file_format_tests_on_file_format_profile_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_format_tests_on_file_format_profile_id ON public.file_format_tests USING btree (file_format_profile_id);


--
-- Name: index_file_groups_on_acquisition_method; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_groups_on_acquisition_method ON public.file_groups USING btree (acquisition_method);


--
-- Name: index_file_groups_on_cfs_root; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_file_groups_on_cfs_root ON public.file_groups USING btree (cfs_root);


--
-- Name: index_file_groups_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_groups_on_collection_id ON public.file_groups USING btree (collection_id);


--
-- Name: index_file_groups_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_groups_on_type ON public.file_groups USING btree (type);


--
-- Name: index_file_groups_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_groups_on_updated_at ON public.file_groups USING btree (updated_at);


--
-- Name: index_fits_data_on_cfs_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_fits_data_on_cfs_file_id ON public.fits_data USING btree (cfs_file_id);


--
-- Name: index_fixity_check_results_on_cfs_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fixity_check_results_on_cfs_file_id ON public.fixity_check_results USING btree (cfs_file_id);


--
-- Name: index_fixity_check_results_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fixity_check_results_on_created_at ON public.fixity_check_results USING btree (created_at);


--
-- Name: index_fixity_check_results_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fixity_check_results_on_status ON public.fixity_check_results USING btree (status);


--
-- Name: index_institutions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_institutions_on_name ON public.institutions USING btree (name);


--
-- Name: index_institutions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_institutions_on_updated_at ON public.institutions USING btree (updated_at);


--
-- Name: index_items_on_barcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_barcode ON public.items USING btree (barcode);


--
-- Name: index_items_on_bib_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_bib_id ON public.items USING btree (bib_id);


--
-- Name: index_items_on_call_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_call_number ON public.items USING btree (call_number);


--
-- Name: index_items_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_cfs_directory_id ON public.items USING btree (cfs_directory_id);


--
-- Name: index_items_on_oclc_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_oclc_number ON public.items USING btree (oclc_number);


--
-- Name: index_items_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_project_id ON public.items USING btree (project_id);


--
-- Name: index_items_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_status ON public.items USING btree (status);


--
-- Name: index_job_cfs_initial_directory_assessments_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_cfs_initial_directory_assessments_on_cfs_directory_id ON public.job_cfs_initial_directory_assessments USING btree (cfs_directory_id);


--
-- Name: index_job_cfs_initial_directory_assessments_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_cfs_initial_directory_assessments_on_file_group_id ON public.job_cfs_initial_directory_assessments USING btree (file_group_id);


--
-- Name: index_job_cfs_initial_file_group_assessments_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_cfs_initial_file_group_assessments_on_file_group_id ON public.job_cfs_initial_file_group_assessments USING btree (file_group_id);


--
-- Name: index_job_fits_content_type_batches_on_content_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_job_fits_content_type_batches_on_content_type_id ON public.job_fits_content_type_batches USING btree (content_type_id);


--
-- Name: index_job_fits_content_type_batches_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fits_content_type_batches_on_user_id ON public.job_fits_content_type_batches USING btree (user_id);


--
-- Name: index_job_fits_directories_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fits_directories_on_cfs_directory_id ON public.job_fits_directories USING btree (cfs_directory_id);


--
-- Name: index_job_fits_directories_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fits_directories_on_file_group_id ON public.job_fits_directories USING btree (file_group_id);


--
-- Name: index_job_fits_directory_trees_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fits_directory_trees_on_cfs_directory_id ON public.job_fits_directory_trees USING btree (cfs_directory_id);


--
-- Name: index_job_fits_directory_trees_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fits_directory_trees_on_file_group_id ON public.job_fits_directory_trees USING btree (file_group_id);


--
-- Name: index_job_fits_file_extension_batches_on_file_extension_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_job_fits_file_extension_batches_on_file_extension_id ON public.job_fits_file_extension_batches USING btree (file_extension_id);


--
-- Name: index_job_fits_file_extension_batches_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fits_file_extension_batches_on_user_id ON public.job_fits_file_extension_batches USING btree (user_id);


--
-- Name: index_job_fixity_checks_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fixity_checks_on_cfs_directory_id ON public.job_fixity_checks USING btree (cfs_directory_id);


--
-- Name: index_job_fixity_checks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_fixity_checks_on_user_id ON public.job_fixity_checks USING btree (user_id);


--
-- Name: index_job_ingest_staging_deletes_on_external_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_ingest_staging_deletes_on_external_file_group_id ON public.job_ingest_staging_deletes USING btree (external_file_group_id);


--
-- Name: index_job_ingest_staging_deletes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_ingest_staging_deletes_on_user_id ON public.job_ingest_staging_deletes USING btree (user_id);


--
-- Name: index_job_item_bulk_imports_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_item_bulk_imports_on_project_id ON public.job_item_bulk_imports USING btree (project_id);


--
-- Name: index_job_item_bulk_imports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_item_bulk_imports_on_user_id ON public.job_item_bulk_imports USING btree (user_id);


--
-- Name: index_job_report_cfs_directory_manifests_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_report_cfs_directory_manifests_on_cfs_directory_id ON public.job_report_cfs_directory_manifests USING btree (cfs_directory_id);


--
-- Name: index_job_report_cfs_directory_manifests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_report_cfs_directory_manifests_on_user_id ON public.job_report_cfs_directory_manifests USING btree (user_id);


--
-- Name: index_job_report_cfs_directory_maps_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_report_cfs_directory_maps_on_cfs_directory_id ON public.job_report_cfs_directory_maps USING btree (cfs_directory_id);


--
-- Name: index_job_report_cfs_directory_maps_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_report_cfs_directory_maps_on_user_id ON public.job_report_cfs_directory_maps USING btree (user_id);


--
-- Name: index_job_report_producers_on_producer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_report_producers_on_producer_id ON public.job_report_producers USING btree (producer_id);


--
-- Name: index_job_report_producers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_report_producers_on_user_id ON public.job_report_producers USING btree (user_id);


--
-- Name: index_job_virus_scans_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_virus_scans_on_updated_at ON public.job_virus_scans USING btree (updated_at);


--
-- Name: index_logical_extensions_on_extension_and_description; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_logical_extensions_on_extension_and_description ON public.logical_extensions USING btree (extension, description);


--
-- Name: index_medusa_uuids_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_medusa_uuids_on_uuid ON public.medusa_uuids USING btree (uuid);


--
-- Name: index_medusa_uuids_on_uuidable_id_and_uuidable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_medusa_uuids_on_uuidable_id_and_uuidable_type ON public.medusa_uuids USING btree (uuidable_id, uuidable_type);


--
-- Name: index_people_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_email ON public.people USING btree (email);


--
-- Name: index_people_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_on_updated_at ON public.people USING btree (updated_at);


--
-- Name: index_producers_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_producers_on_updated_at ON public.producers USING btree (updated_at);


--
-- Name: index_production_units_on_administrator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_production_units_on_administrator_id ON public.producers USING btree (administrator_id);


--
-- Name: index_projects_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_collection_id ON public.projects USING btree (collection_id);


--
-- Name: index_projects_on_collection_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_collection_uuid ON public.projects USING btree (collection_uuid);


--
-- Name: index_pronoms_on_file_format_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pronoms_on_file_format_id ON public.pronoms USING btree (file_format_id);


--
-- Name: index_red_flags_on_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_red_flags_on_priority ON public.red_flags USING btree (priority);


--
-- Name: index_red_flags_on_red_flaggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_red_flags_on_red_flaggable_id ON public.red_flags USING btree (red_flaggable_id);


--
-- Name: index_red_flags_on_red_flaggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_red_flags_on_red_flaggable_type ON public.red_flags USING btree (red_flaggable_type);


--
-- Name: index_red_flags_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_red_flags_on_status ON public.red_flags USING btree (status);


--
-- Name: index_red_flags_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_red_flags_on_updated_at ON public.red_flags USING btree (updated_at);


--
-- Name: index_related_file_format_joins_on_file_format_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_file_format_joins_on_file_format_id ON public.related_file_format_joins USING btree (file_format_id);


--
-- Name: index_related_file_format_joins_on_related_file_format_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_file_format_joins_on_related_file_format_id ON public.related_file_format_joins USING btree (related_file_format_id);


--
-- Name: index_related_file_group_joins_on_source_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_file_group_joins_on_source_file_group_id ON public.related_file_group_joins USING btree (source_file_group_id);


--
-- Name: index_related_file_group_joins_on_target_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_file_group_joins_on_target_file_group_id ON public.related_file_group_joins USING btree (target_file_group_id);


--
-- Name: index_related_file_group_joins_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_related_file_group_joins_on_updated_at ON public.related_file_group_joins USING btree (updated_at);


--
-- Name: index_repositories_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_contact_id ON public.repositories USING btree (contact_id);


--
-- Name: index_repositories_on_institution_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_institution_id ON public.repositories USING btree (institution_id);


--
-- Name: index_repositories_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repositories_on_updated_at ON public.repositories USING btree (updated_at);


--
-- Name: index_resource_typeable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_typeable_id ON public.resource_typeable_resource_type_joins USING btree (resource_typeable_id);


--
-- Name: index_resource_typeable_resource_type_joins_on_resource_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_typeable_resource_type_joins_on_resource_type_id ON public.resource_typeable_resource_type_joins USING btree (resource_type_id);


--
-- Name: index_resource_typeable_resource_type_joins_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_typeable_resource_type_joins_on_updated_at ON public.resource_typeable_resource_type_joins USING btree (updated_at);


--
-- Name: index_resource_types_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_resource_types_on_updated_at ON public.resource_types USING btree (updated_at);


--
-- Name: index_rights_declarations_on_rights_declarable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rights_declarations_on_rights_declarable_id ON public.rights_declarations USING btree (rights_declarable_id);


--
-- Name: index_rights_declarations_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rights_declarations_on_updated_at ON public.rights_declarations USING btree (updated_at);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_session_id ON public.sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_updated_at ON public.sessions USING btree (updated_at);


--
-- Name: index_storage_media_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_storage_media_on_updated_at ON public.storage_media USING btree (updated_at);


--
-- Name: index_subcollection_joins_on_child_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subcollection_joins_on_child_collection_id ON public.subcollection_joins USING btree (child_collection_id);


--
-- Name: index_subcollection_joins_on_parent_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subcollection_joins_on_parent_collection_id ON public.subcollection_joins USING btree (parent_collection_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_uid ON public.users USING btree (uid);


--
-- Name: index_users_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_updated_at ON public.users USING btree (updated_at);


--
-- Name: index_virus_scans_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_virus_scans_on_file_group_id ON public.virus_scans USING btree (file_group_id);


--
-- Name: index_virus_scans_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_virus_scans_on_updated_at ON public.virus_scans USING btree (updated_at);


--
-- Name: index_workflow_accrual_comments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_comments_on_user_id ON public.workflow_accrual_comments USING btree (user_id);


--
-- Name: index_workflow_accrual_comments_on_workflow_accrual_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_comments_on_workflow_accrual_job_id ON public.workflow_accrual_comments USING btree (workflow_accrual_job_id);


--
-- Name: index_workflow_accrual_conflicts_on_different; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_conflicts_on_different ON public.workflow_accrual_conflicts USING btree (different);


--
-- Name: index_workflow_accrual_conflicts_on_workflow_accrual_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_conflicts_on_workflow_accrual_job_id ON public.workflow_accrual_conflicts USING btree (workflow_accrual_job_id);


--
-- Name: index_workflow_accrual_directories_on_workflow_accrual_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_directories_on_workflow_accrual_job_id ON public.workflow_accrual_directories USING btree (workflow_accrual_job_id);


--
-- Name: index_workflow_accrual_files_on_workflow_accrual_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_files_on_workflow_accrual_job_id ON public.workflow_accrual_files USING btree (workflow_accrual_job_id);


--
-- Name: index_workflow_accrual_jobs_on_cfs_directory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_jobs_on_cfs_directory_id ON public.workflow_accrual_jobs USING btree (cfs_directory_id);


--
-- Name: index_workflow_accrual_jobs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_jobs_on_user_id ON public.workflow_accrual_jobs USING btree (user_id);


--
-- Name: index_workflow_accrual_keys_on_workflow_accrual_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_accrual_keys_on_workflow_accrual_job_id ON public.workflow_accrual_keys USING btree (workflow_accrual_job_id);


--
-- Name: index_workflow_file_group_deletes_on_approver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_file_group_deletes_on_approver_id ON public.workflow_file_group_deletes USING btree (approver_id);


--
-- Name: index_workflow_file_group_deletes_on_cached_collection_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_file_group_deletes_on_cached_collection_uuid ON public.workflow_file_group_deletes USING btree (cached_collection_uuid);


--
-- Name: index_workflow_file_group_deletes_on_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_file_group_deletes_on_file_group_id ON public.workflow_file_group_deletes USING btree (file_group_id);


--
-- Name: index_workflow_file_group_deletes_on_requester_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_file_group_deletes_on_requester_id ON public.workflow_file_group_deletes USING btree (requester_id);


--
-- Name: index_workflow_file_group_deletes_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_file_group_deletes_on_state ON public.workflow_file_group_deletes USING btree (state);


--
-- Name: index_workflow_ingests_on_bit_level_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_ingests_on_bit_level_file_group_id ON public.workflow_ingests USING btree (bit_level_file_group_id);


--
-- Name: index_workflow_ingests_on_external_file_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_workflow_ingests_on_external_file_group_id ON public.workflow_ingests USING btree (external_file_group_id);


--
-- Name: index_workflow_ingests_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_ingests_on_updated_at ON public.workflow_ingests USING btree (updated_at);


--
-- Name: index_workflow_ingests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workflow_ingests_on_user_id ON public.workflow_ingests USING btree (user_id);


--
-- Name: unique_cascaded_events; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_cascaded_events ON public.cascaded_event_joins USING btree (cascaded_eventable_type, cascaded_eventable_id, event_id);


--
-- Name: unique_cascaded_red_flags; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_cascaded_red_flags ON public.cascaded_red_flag_joins USING btree (cascaded_red_flaggable_type, cascaded_red_flaggable_id, red_flag_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: wfad_job_and_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX wfad_job_and_name_idx ON public.workflow_accrual_directories USING btree (workflow_accrual_job_id, name);


--
-- Name: wfaf_job_and_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX wfaf_job_and_name_idx ON public.workflow_accrual_files USING btree (workflow_accrual_job_id, name);


--
-- Name: wfaj_cfs_dir_id_and_staging_path_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX wfaj_cfs_dir_id_and_staging_path_idx ON public.workflow_accrual_jobs USING btree (cfs_directory_id, staging_path);


--
-- Name: workflow_item_ingest_requests_item_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX workflow_item_ingest_requests_item_index ON public.workflow_item_ingest_requests USING btree (item_id);


--
-- Name: workflow_item_ingest_requests_pii_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workflow_item_ingest_requests_pii_index ON public.workflow_item_ingest_requests USING btree (workflow_project_item_ingest_id);


--
-- Name: access_system_collection_joins access_system_collection_joins_touch_access_system_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER access_system_collection_joins_touch_access_system_trigger AFTER INSERT OR DELETE OR UPDATE ON public.access_system_collection_joins FOR EACH ROW EXECUTE PROCEDURE public.access_system_collection_joins_touch_access_system();


--
-- Name: access_system_collection_joins access_system_collection_joins_touch_collection_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER access_system_collection_joins_touch_collection_trigger AFTER INSERT OR DELETE OR UPDATE ON public.access_system_collection_joins FOR EACH ROW EXECUTE PROCEDURE public.access_system_collection_joins_touch_collection();


--
-- Name: assessments assessments_touch_storage_medium_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER assessments_touch_storage_medium_trigger AFTER INSERT OR DELETE OR UPDATE ON public.assessments FOR EACH ROW EXECUTE PROCEDURE public.assessments_touch_storage_medium();


--
-- Name: cfs_directories cfs_dir_update_bit_level_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cfs_dir_update_bit_level_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON public.cfs_directories FOR EACH ROW EXECUTE PROCEDURE public.cfs_dir_update_bit_level_file_group();


--
-- Name: cfs_directories cfs_dir_update_cfs_dir_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cfs_dir_update_cfs_dir_trigger AFTER INSERT OR DELETE OR UPDATE ON public.cfs_directories FOR EACH ROW EXECUTE PROCEDURE public.cfs_dir_update_cfs_dir();


--
-- Name: cfs_files cfs_file_update_cfs_directory_and_extension_and_content_type_tr; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cfs_file_update_cfs_directory_and_extension_and_content_type_tr AFTER INSERT OR DELETE OR UPDATE ON public.cfs_files FOR EACH ROW EXECUTE PROCEDURE public.cfs_file_update_cfs_directory_and_extension_and_content_type();


--
-- Name: cfs_files cfs_files_touch_cfs_directory_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cfs_files_touch_cfs_directory_trigger AFTER INSERT OR DELETE OR UPDATE ON public.cfs_files FOR EACH ROW EXECUTE PROCEDURE public.cfs_files_touch_cfs_directory();


--
-- Name: cfs_files cfs_files_touch_content_type_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cfs_files_touch_content_type_trigger AFTER INSERT OR DELETE OR UPDATE ON public.cfs_files FOR EACH ROW EXECUTE PROCEDURE public.cfs_files_touch_content_type();


--
-- Name: cfs_files cfs_files_touch_file_extension_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER cfs_files_touch_file_extension_trigger AFTER INSERT OR DELETE OR UPDATE ON public.cfs_files FOR EACH ROW EXECUTE PROCEDURE public.cfs_files_touch_file_extension();


--
-- Name: collections collections_touch_repository_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER collections_touch_repository_trigger AFTER INSERT OR DELETE OR UPDATE ON public.collections FOR EACH ROW EXECUTE PROCEDURE public.collections_touch_repository();


--
-- Name: file_groups file_groups_touch_collection_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER file_groups_touch_collection_trigger AFTER INSERT OR DELETE OR UPDATE ON public.file_groups FOR EACH ROW EXECUTE PROCEDURE public.file_groups_touch_collection();


--
-- Name: file_groups file_groups_touch_producer_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER file_groups_touch_producer_trigger AFTER INSERT OR DELETE OR UPDATE ON public.file_groups FOR EACH ROW EXECUTE PROCEDURE public.file_groups_touch_producer();


--
-- Name: job_cfs_directory_exports job_cfs_directory_exports_touch_cfs_directory_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_cfs_directory_exports_touch_cfs_directory_trigger AFTER INSERT OR DELETE OR UPDATE ON public.job_cfs_directory_exports FOR EACH ROW EXECUTE PROCEDURE public.job_cfs_directory_exports_touch_cfs_directory();


--
-- Name: job_cfs_directory_exports job_cfs_directory_exports_touch_user_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_cfs_directory_exports_touch_user_trigger AFTER INSERT OR DELETE OR UPDATE ON public.job_cfs_directory_exports FOR EACH ROW EXECUTE PROCEDURE public.job_cfs_directory_exports_touch_user();


--
-- Name: job_cfs_initial_file_group_assessments job_cfs_initial_file_group_assessments_touch_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_cfs_initial_file_group_assessments_touch_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON public.job_cfs_initial_file_group_assessments FOR EACH ROW EXECUTE PROCEDURE public.job_cfs_initial_file_group_assessments_touch_file_group();


--
-- Name: job_fits_directories job_fits_directories_touch_cfs_directory_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_fits_directories_touch_cfs_directory_trigger AFTER INSERT OR DELETE OR UPDATE ON public.job_fits_directories FOR EACH ROW EXECUTE PROCEDURE public.job_fits_directories_touch_cfs_directory();


--
-- Name: job_fits_directories job_fits_directories_touch_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_fits_directories_touch_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON public.job_fits_directories FOR EACH ROW EXECUTE PROCEDURE public.job_fits_directories_touch_file_group();


--
-- Name: job_fits_directory_trees job_fits_directory_trees_touch_cfs_directory_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_fits_directory_trees_touch_cfs_directory_trigger AFTER INSERT OR DELETE OR UPDATE ON public.job_fits_directory_trees FOR EACH ROW EXECUTE PROCEDURE public.job_fits_directory_trees_touch_cfs_directory();


--
-- Name: job_fits_directory_trees job_fits_directory_trees_touch_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_fits_directory_trees_touch_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON public.job_fits_directory_trees FOR EACH ROW EXECUTE PROCEDURE public.job_fits_directory_trees_touch_file_group();


--
-- Name: job_ingest_staging_deletes job_ingest_staging_deletes_touch_external_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_ingest_staging_deletes_touch_external_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON public.job_ingest_staging_deletes FOR EACH ROW EXECUTE PROCEDURE public.job_ingest_staging_deletes_touch_external_file_group();


--
-- Name: job_ingest_staging_deletes job_ingest_staging_deletes_touch_user_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_ingest_staging_deletes_touch_user_trigger AFTER INSERT OR DELETE OR UPDATE ON public.job_ingest_staging_deletes FOR EACH ROW EXECUTE PROCEDURE public.job_ingest_staging_deletes_touch_user();


--
-- Name: job_virus_scans job_virus_scans_touch_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER job_virus_scans_touch_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON public.job_virus_scans FOR EACH ROW EXECUTE PROCEDURE public.job_virus_scans_touch_file_group();


--
-- Name: projects projects_touch_collection_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER projects_touch_collection_trigger AFTER INSERT OR DELETE OR UPDATE ON public.projects FOR EACH ROW EXECUTE PROCEDURE public.projects_touch_collection();


--
-- Name: related_file_group_joins related_file_group_joins_touch_source_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER related_file_group_joins_touch_source_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON public.related_file_group_joins FOR EACH ROW EXECUTE PROCEDURE public.related_file_group_joins_touch_source_file_group();


--
-- Name: related_file_group_joins related_file_group_joins_touch_target_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER related_file_group_joins_touch_target_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON public.related_file_group_joins FOR EACH ROW EXECUTE PROCEDURE public.related_file_group_joins_touch_target_file_group();


--
-- Name: repositories repositories_touch_institution_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER repositories_touch_institution_trigger AFTER INSERT OR DELETE OR UPDATE ON public.repositories FOR EACH ROW EXECUTE PROCEDURE public.repositories_touch_institution();


--
-- Name: resource_typeable_resource_type_joins resource_typeable_resource_type_joins_touch_resource_type_trigg; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER resource_typeable_resource_type_joins_touch_resource_type_trigg AFTER INSERT OR DELETE OR UPDATE ON public.resource_typeable_resource_type_joins FOR EACH ROW EXECUTE PROCEDURE public.resource_typeable_resource_type_joins_touch_resource_type();


--
-- Name: virus_scans virus_scans_touch_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER virus_scans_touch_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON public.virus_scans FOR EACH ROW EXECUTE PROCEDURE public.virus_scans_touch_file_group();


--
-- Name: workflow_accrual_comments workflow_accrual_comments_touch_workflow_accrual_job_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_comments_touch_workflow_accrual_job_trigger AFTER INSERT OR DELETE OR UPDATE ON public.workflow_accrual_comments FOR EACH ROW EXECUTE PROCEDURE public.workflow_accrual_comments_touch_workflow_accrual_job();


--
-- Name: workflow_accrual_conflicts workflow_accrual_conflicts_touch_workflow_accrual_job_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_conflicts_touch_workflow_accrual_job_trigger AFTER INSERT OR DELETE OR UPDATE ON public.workflow_accrual_conflicts FOR EACH ROW EXECUTE PROCEDURE public.workflow_accrual_conflicts_touch_workflow_accrual_job();


--
-- Name: workflow_accrual_directories workflow_accrual_directories_touch_workflow_accrual_job_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_directories_touch_workflow_accrual_job_trigger AFTER INSERT OR DELETE OR UPDATE ON public.workflow_accrual_directories FOR EACH ROW EXECUTE PROCEDURE public.workflow_accrual_directories_touch_workflow_accrual_job();


--
-- Name: workflow_accrual_files workflow_accrual_files_touch_workflow_accrual_job_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_files_touch_workflow_accrual_job_trigger AFTER INSERT OR DELETE OR UPDATE ON public.workflow_accrual_files FOR EACH ROW EXECUTE PROCEDURE public.workflow_accrual_files_touch_workflow_accrual_job();


--
-- Name: workflow_accrual_jobs workflow_accrual_jobs_touch_cfs_directory_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_jobs_touch_cfs_directory_trigger AFTER INSERT OR DELETE OR UPDATE ON public.workflow_accrual_jobs FOR EACH ROW EXECUTE PROCEDURE public.workflow_accrual_jobs_touch_cfs_directory();


--
-- Name: workflow_accrual_jobs workflow_accrual_jobs_touch_user_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_accrual_jobs_touch_user_trigger AFTER INSERT OR DELETE OR UPDATE ON public.workflow_accrual_jobs FOR EACH ROW EXECUTE PROCEDURE public.workflow_accrual_jobs_touch_user();


--
-- Name: workflow_ingests workflow_ingests_touch_bit_level_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_ingests_touch_bit_level_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON public.workflow_ingests FOR EACH ROW EXECUTE PROCEDURE public.workflow_ingests_touch_bit_level_file_group();


--
-- Name: workflow_ingests workflow_ingests_touch_external_file_group_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_ingests_touch_external_file_group_trigger AFTER INSERT OR DELETE OR UPDATE ON public.workflow_ingests FOR EACH ROW EXECUTE PROCEDURE public.workflow_ingests_touch_external_file_group();


--
-- Name: workflow_ingests workflow_ingests_touch_user_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER workflow_ingests_touch_user_trigger AFTER INSERT OR DELETE OR UPDATE ON public.workflow_ingests FOR EACH ROW EXECUTE PROCEDURE public.workflow_ingests_touch_user();


--
-- Name: file_format_profiles_file_extensions_joins fk_rails_04822aba51; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_profiles_file_extensions_joins
    ADD CONSTRAINT fk_rails_04822aba51 FOREIGN KEY (file_extension_id) REFERENCES public.file_extensions(id);


--
-- Name: workflow_accrual_conflicts fk_rails_07ebf5783f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_conflicts
    ADD CONSTRAINT fk_rails_07ebf5783f FOREIGN KEY (workflow_accrual_job_id) REFERENCES public.workflow_accrual_jobs(id);


--
-- Name: workflow_accrual_jobs fk_rails_0d41a20552; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_jobs
    ADD CONSTRAINT fk_rails_0d41a20552 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: job_report_cfs_directory_maps fk_rails_1a48857b12; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_report_cfs_directory_maps
    ADD CONSTRAINT fk_rails_1a48857b12 FOREIGN KEY (cfs_directory_id) REFERENCES public.cfs_directories(id);


--
-- Name: file_format_tests_file_format_test_reasons_joins fk_rails_1db34f98ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_tests_file_format_test_reasons_joins
    ADD CONSTRAINT fk_rails_1db34f98ff FOREIGN KEY (file_format_test_id) REFERENCES public.file_format_tests(id);


--
-- Name: job_fits_file_extension_batches fk_rails_2214d78ff1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fits_file_extension_batches
    ADD CONSTRAINT fk_rails_2214d78ff1 FOREIGN KEY (file_extension_id) REFERENCES public.file_extensions(id);


--
-- Name: workflow_accrual_comments fk_rails_2258e947c4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_comments
    ADD CONSTRAINT fk_rails_2258e947c4 FOREIGN KEY (workflow_accrual_job_id) REFERENCES public.workflow_accrual_jobs(id);


--
-- Name: job_report_cfs_directory_manifests fk_rails_22c26c34ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_report_cfs_directory_manifests
    ADD CONSTRAINT fk_rails_22c26c34ee FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: job_report_producers fk_rails_23bd1f6d28; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_report_producers
    ADD CONSTRAINT fk_rails_23bd1f6d28 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: file_format_notes fk_rails_23d6ecdef7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_notes
    ADD CONSTRAINT fk_rails_23d6ecdef7 FOREIGN KEY (file_format_id) REFERENCES public.file_formats(id);


--
-- Name: archived_accrual_jobs fk_rails_242362ff14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archived_accrual_jobs
    ADD CONSTRAINT fk_rails_242362ff14 FOREIGN KEY (cfs_directory_id) REFERENCES public.cfs_directories(id);


--
-- Name: file_format_profiles_file_extensions_joins fk_rails_264edd65c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_profiles_file_extensions_joins
    ADD CONSTRAINT fk_rails_264edd65c3 FOREIGN KEY (file_format_profile_id) REFERENCES public.file_format_profiles(id);


--
-- Name: file_format_tests_file_format_test_reasons_joins fk_rails_2c4d650843; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_tests_file_format_test_reasons_joins
    ADD CONSTRAINT fk_rails_2c4d650843 FOREIGN KEY (file_format_test_reason_id) REFERENCES public.file_format_test_reasons(id);


--
-- Name: cfs_files fk_rails_2d8d8e95f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfs_files
    ADD CONSTRAINT fk_rails_2d8d8e95f6 FOREIGN KEY (file_extension_id) REFERENCES public.file_extensions(id);


--
-- Name: workflow_accrual_files fk_rails_321123b6a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_files
    ADD CONSTRAINT fk_rails_321123b6a8 FOREIGN KEY (workflow_accrual_job_id) REFERENCES public.workflow_accrual_jobs(id);


--
-- Name: collection_virtual_repository_joins fk_rails_3c52875c13; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_virtual_repository_joins
    ADD CONSTRAINT fk_rails_3c52875c13 FOREIGN KEY (virtual_repository_id) REFERENCES public.virtual_repositories(id);


--
-- Name: file_formats_file_format_profiles_joins fk_rails_3e0ef5d079; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_formats_file_format_profiles_joins
    ADD CONSTRAINT fk_rails_3e0ef5d079 FOREIGN KEY (file_format_profile_id) REFERENCES public.file_format_profiles(id);


--
-- Name: job_fits_content_type_batches fk_rails_49490359d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fits_content_type_batches
    ADD CONSTRAINT fk_rails_49490359d8 FOREIGN KEY (content_type_id) REFERENCES public.content_types(id);


--
-- Name: job_report_producers fk_rails_4b642d3bd5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_report_producers
    ADD CONSTRAINT fk_rails_4b642d3bd5 FOREIGN KEY (producer_id) REFERENCES public.producers(id);


--
-- Name: workflow_item_ingest_requests fk_rails_5409004c7a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_item_ingest_requests
    ADD CONSTRAINT fk_rails_5409004c7a FOREIGN KEY (workflow_project_item_ingest_id) REFERENCES public.workflow_project_item_ingests(id);


--
-- Name: fixity_check_results fk_rails_58d613c356; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fixity_check_results
    ADD CONSTRAINT fk_rails_58d613c356 FOREIGN KEY (cfs_file_id) REFERENCES public.cfs_files(id);


--
-- Name: job_report_cfs_directory_manifests fk_rails_5a8bfa928b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_report_cfs_directory_manifests
    ADD CONSTRAINT fk_rails_5a8bfa928b FOREIGN KEY (cfs_directory_id) REFERENCES public.cfs_directories(id);


--
-- Name: cascaded_event_joins fk_rails_5f90452cff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cascaded_event_joins
    ADD CONSTRAINT fk_rails_5f90452cff FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: archived_accrual_jobs fk_rails_62dc01f91f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archived_accrual_jobs
    ADD CONSTRAINT fk_rails_62dc01f91f FOREIGN KEY (file_group_id) REFERENCES public.file_groups(id);


--
-- Name: job_fits_file_extension_batches fk_rails_75f09068b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fits_file_extension_batches
    ADD CONSTRAINT fk_rails_75f09068b2 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: collection_virtual_repository_joins fk_rails_7a05f7a57b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_virtual_repository_joins
    ADD CONSTRAINT fk_rails_7a05f7a57b FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: job_item_bulk_imports fk_rails_7fe769aa60; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_item_bulk_imports
    ADD CONSTRAINT fk_rails_7fe769aa60 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: workflow_accrual_directories fk_rails_814510e4f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_directories
    ADD CONSTRAINT fk_rails_814510e4f4 FOREIGN KEY (workflow_accrual_job_id) REFERENCES public.workflow_accrual_jobs(id);


--
-- Name: job_report_cfs_directory_maps fk_rails_88ef33b97d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_report_cfs_directory_maps
    ADD CONSTRAINT fk_rails_88ef33b97d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: workflow_accrual_comments fk_rails_8aaf1a7eb8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_comments
    ADD CONSTRAINT fk_rails_8aaf1a7eb8 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: file_format_tests fk_rails_8c3cd8e21a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_tests
    ADD CONSTRAINT fk_rails_8c3cd8e21a FOREIGN KEY (cfs_file_id) REFERENCES public.cfs_files(id);


--
-- Name: file_format_notes fk_rails_9a724fc755; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_notes
    ADD CONSTRAINT fk_rails_9a724fc755 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: job_fixity_checks fk_rails_a920535132; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fixity_checks
    ADD CONSTRAINT fk_rails_a920535132 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: job_item_bulk_imports fk_rails_ac902747ea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_item_bulk_imports
    ADD CONSTRAINT fk_rails_ac902747ea FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: workflow_item_ingest_requests fk_rails_b54106f343; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_item_ingest_requests
    ADD CONSTRAINT fk_rails_b54106f343 FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- Name: file_formats_file_format_profiles_joins fk_rails_bdfc264c54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_formats_file_format_profiles_joins
    ADD CONSTRAINT fk_rails_bdfc264c54 FOREIGN KEY (file_format_id) REFERENCES public.file_formats(id);


--
-- Name: file_format_tests fk_rails_c986487b1e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_tests
    ADD CONSTRAINT fk_rails_c986487b1e FOREIGN KEY (file_format_profile_id) REFERENCES public.file_format_profiles(id);


--
-- Name: workflow_accrual_jobs fk_rails_cf395e5550; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workflow_accrual_jobs
    ADD CONSTRAINT fk_rails_cf395e5550 FOREIGN KEY (cfs_directory_id) REFERENCES public.cfs_directories(id);


--
-- Name: cfs_files fk_rails_cfaf129e28; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfs_files
    ADD CONSTRAINT fk_rails_cfaf129e28 FOREIGN KEY (content_type_id) REFERENCES public.content_types(id);


--
-- Name: file_format_profiles_content_types_joins fk_rails_d1c1c35cf5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_profiles_content_types_joins
    ADD CONSTRAINT fk_rails_d1c1c35cf5 FOREIGN KEY (file_format_profile_id) REFERENCES public.file_format_profiles(id);


--
-- Name: projects fk_rails_d5e71e625f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_d5e71e625f FOREIGN KEY (collection_id) REFERENCES public.collections(id);


--
-- Name: job_fits_content_type_batches fk_rails_d7b90994ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_fits_content_type_batches
    ADD CONSTRAINT fk_rails_d7b90994ef FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: archived_accrual_jobs fk_rails_d8a84160a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archived_accrual_jobs
    ADD CONSTRAINT fk_rails_d8a84160a7 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: file_format_profiles_content_types_joins fk_rails_f411565e2a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_profiles_content_types_joins
    ADD CONSTRAINT fk_rails_f411565e2a FOREIGN KEY (content_type_id) REFERENCES public.content_types(id);


--
-- Name: file_format_normalization_paths fk_rails_f4f83033da; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_format_normalization_paths
    ADD CONSTRAINT fk_rails_f4f83033da FOREIGN KEY (file_format_id) REFERENCES public.file_formats(id);


--
-- Name: items fk_rails_f6abf55b81; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT fk_rails_f6abf55b81 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: pronoms fk_rails_fdd3dd4403; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pronoms
    ADD CONSTRAINT fk_rails_fdd3dd4403 FOREIGN KEY (file_format_id) REFERENCES public.file_formats(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20120723183454'),
('20120723212328'),
('20120724205839'),
('20120725162036'),
('20120725202659'),
('20120726164948'),
('20120726165438'),
('20120726170920'),
('20120726210554'),
('20120727170444'),
('20120727190840'),
('20120727205022'),
('20120727211800'),
('20120727212826'),
('20120727215843'),
('20120727222206'),
('20120730190034'),
('20120730204420'),
('20120731172956'),
('20120731174612'),
('20120731195332'),
('20120731200900'),
('20120731222552'),
('20120801141451'),
('20120801193922'),
('20120822151305'),
('20120822153335'),
('20120823200906'),
('20120823204310'),
('20120828182138'),
('20120829153644'),
('20120830210252'),
('20120910150517'),
('20120910151633'),
('20120910153521'),
('20120910162212'),
('20120917195429'),
('20120918181620'),
('20120925175714'),
('20120925175758'),
('20120925214848'),
('20120925221448'),
('20120928195102'),
('20121004210537'),
('20121008164346'),
('20121024154347'),
('20121106182743'),
('20121107205541'),
('20121108180509'),
('20121219211723'),
('20121219211931'),
('20130125155156'),
('20130211181738'),
('20130211222200'),
('20130212212413'),
('20130213152311'),
('20130213162526'),
('20130214170800'),
('20130301165908'),
('20130304190239'),
('20130307181108'),
('20130311162054'),
('20130327212251'),
('20130328185811'),
('20130408151257'),
('20130408223729'),
('20130424222640'),
('20130426145321'),
('20130426151142'),
('20130430184832'),
('20130501022611'),
('20130516182122'),
('20130523204024'),
('20130524143202'),
('20130528151355'),
('20130528152210'),
('20130531164842'),
('20130531172551'),
('20130531180926'),
('20130610171240'),
('20130620162758'),
('20130628204524'),
('20130628204724'),
('20130628204922'),
('20130912165653'),
('20130912190139'),
('20130930173250'),
('20140123184422'),
('20140130171207'),
('20140206194153'),
('20140206195254'),
('20140306174156'),
('20140306220612'),
('20140311195100'),
('20140311195745'),
('20140311211633'),
('20140312143243'),
('20140313224433'),
('20140318193810'),
('20140318193904'),
('20140325160348'),
('20140325161140'),
('20140331185904'),
('20140331190400'),
('20140424210638'),
('20140517143007'),
('20140527175510'),
('20140527190504'),
('20140613165040'),
('20140708200003'),
('20140708220726'),
('20140708223302'),
('20140709153705'),
('20140730195513'),
('20140731213225'),
('20140801204239'),
('20140821180028'),
('20140821185728'),
('20140919195200'),
('20140919211418'),
('20141002155435'),
('20141002155446'),
('20141006163154'),
('20141007204736'),
('20141008134937'),
('20141008213501'),
('20141009210118'),
('20141010214341'),
('20141111171712'),
('20141111220854'),
('20141117192815'),
('20141119223036'),
('20141119230908'),
('20141124221217'),
('20141124221933'),
('20141202170603'),
('20141204165919'),
('20141208215312'),
('20141217152139'),
('20141217155120'),
('20141219200334'),
('20141222162152'),
('20141223214209'),
('20141229194747'),
('20150107151851'),
('20150115200721'),
('20150120180909'),
('20150120182658'),
('20150120221842'),
('20150126153758'),
('20150128191608'),
('20150128231416'),
('20150129163528'),
('20150129163558'),
('20150129164513'),
('20150129212630'),
('20150129225137'),
('20150129225153'),
('20150210220335'),
('20150210220730'),
('20150217225223'),
('20150424212432'),
('20150424212501'),
('20150507193408'),
('20150507193716'),
('20150507193738'),
('20150508191123'),
('20150521173040'),
('20150529171424'),
('20150617154451'),
('20150908195139'),
('20150916152553'),
('20150917221307'),
('20150918191709'),
('20150928151036'),
('20150928171015'),
('20151006191119'),
('20151006210709'),
('20151007154809'),
('20151008152822'),
('20151008210801'),
('20151008224057'),
('20151008224141'),
('20151009180849'),
('20151013195837'),
('20151014151423'),
('20151019141222'),
('20151030190201'),
('20151030192656'),
('20151104182843'),
('20151104210143'),
('20151112160558'),
('20151201192336'),
('20151202172013'),
('20151203164731'),
('20151214190747'),
('20151214224916'),
('20151215152708'),
('20160126233249'),
('20160202183505'),
('20160302185450'),
('20160302191209'),
('20160302195237'),
('20160322151332'),
('20160330152020'),
('20160401193220'),
('20160411215028'),
('20160419143152'),
('20160419150545'),
('20160504200651'),
('20160504204653'),
('20160505011200'),
('20160518182728'),
('20160531161759'),
('20160531162831'),
('20160610185704'),
('20160610220337'),
('20160621144247'),
('20160805144959'),
('20160805172916'),
('20160805193842'),
('20160805200045'),
('20160815185511'),
('20160819153537'),
('20160824143252'),
('20160825144956'),
('20160908173523'),
('20160915141932'),
('20160919141735'),
('20161021160022'),
('20161027171950'),
('20161103195200'),
('20161107150831'),
('20161216185129'),
('20161216205814'),
('20170120170335'),
('20170120200604'),
('20170306185148'),
('20170309204228'),
('20170331185713'),
('20170516212747'),
('20170526185604'),
('20170526185618'),
('20170531152741'),
('20170710202254'),
('20170809162601'),
('20170823171242'),
('20171012153758'),
('20171113212259'),
('20171116203856'),
('20171117201629'),
('20180222205350'),
('20180223184346'),
('20180223194517'),
('20180223212939'),
('20180223213125'),
('20180226204915'),
('20180319160347'),
('20180515194345'),
('20180730184829'),
('20180820162256'),
('20180820163520'),
('20180820172658'),
('20180820175521'),
('20180820181615'),
('20180820185950'),
('20180820192218'),
('20180820194539'),
('20180820200518'),
('20180820214650'),
('20180829135002'),
('20180831195356'),
('20180831201248'),
('20180918144251'),
('20190220174203'),
('20190227185658'),
('20190322195107'),
('20190412153912'),
('20190418215850'),
('20190418215910'),
('20190422162120'),
('20190422190028'),
('20190503165005'),
('20190503171349'),
('20190523150351'),
('20190614150050'),
('20190614150232'),
('20190718135009');


