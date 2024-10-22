/* practice_set_item triggers */

DELIMITER $$

CREATE TRIGGER trg_practice_set_timestamp_after_item_update
AFTER UPDATE ON practice_set_item
FOR EACH ROW
BEGIN
    UPDATE practice_set
    SET last_edited_timestamp = NOW()
    WHERE id = OLD.practice_set_id;
END $$

DELIMITER ;
/* ========= */

DELIMITER $$

CREATE TRIGGER trg_practice_set_timestamp_after_item_insert
AFTER INSERT ON practice_set_item
FOR EACH ROW
BEGIN
    UPDATE practice_set
    SET last_edited_timestamp = NOW()
    WHERE id = NEW.practice_set_id;
END $$

DELIMITER ;

/* ================= */

DELIMITER $$

CREATE TRIGGER trg_practice_set_timestamp_after_item_delete
AFTER DELETE ON practice_set_item
FOR EACH ROW
BEGIN
    UPDATE practice_set
    SET last_edited_timestamp = NOW()
    WHERE id = OLD.practice_set_id;
END $$

DELIMITER ;

/* ======================== */

/* practice_set trigger */

DELIMITER $$

CREATE TRIGGER trg_practice_set_timestamp_update
BEFORE UPDATE ON practice_set
FOR EACH ROW
BEGIN
    SET NEW.last_edited_timestamp = NOW();
END $$

DELIMITER ;



/* tag triggers */

DELIMITER $$

CREATE TRIGGER trg_practice_set_timestamp_after_tag_update
AFTER UPDATE ON practice_set_tags
FOR EACH ROW
BEGIN
    UPDATE practice_set
    SET last_edited_timestamp = NOW()
    WHERE id = OLD.practice_set_id;
END $$

DELIMITER ;
/* ========= */


DELIMITER $$

CREATE TRIGGER trg_practice_set_timestamp_after_tag_insert
AFTER INSERT ON practice_set_tags
FOR EACH ROW
BEGIN
    UPDATE practice_set
    SET last_edited_timestamp = NOW()
    WHERE id = NEW.practice_set_id;
END $$

DELIMITER ;

/* ================= */

DELIMITER $$

CREATE TRIGGER trg_practice_set_timestamp_after_tag_delete
AFTER DELETE ON practice_set_tags
FOR EACH ROW
BEGIN
    UPDATE practice_set
    SET last_edited_timestamp = NOW()
    WHERE id = OLD.practice_set_id;
END $$

DELIMITER ;

/* ======================== */

DELIMITER $$

CREATE TRIGGER trg_favorite_sets_check_if_set_deleted
BEFORE INSERT ON favorite_practice_sets
FOR EACH ROW
BEGIN
    DECLARE set_deleted INT;

    SELECT is_deleted INTO set_deleted
    FROM practice_set
    WHERE id = NEW.practice_set_id;

    -- If the set is deleted (i.e., is_deleted = 1), prevent the insert
    IF set_deleted = 1 THEN
        SIGNAL SQLSTATE '45000'  -- Custom error state
        SET MESSAGE_TEXT = 'Cannot favorite a deleted practice set.';
    END IF;
END $$

DELIMITER ;


DROP TRIGGER IF EXISTS trg_favorite_sets_check_if_set_private;

DELIMITER $$

CREATE TRIGGER trg_favorite_sets_check_if_set_private
BEFORE INSERT ON favorite_practice_sets
FOR EACH ROW
BEGIN
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
END $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER trg_favorite_sets_remove_if_set_to_private
BEFORE UPDATE ON practice_set
FOR EACH ROW
BEGIN
	IF NEW.private = 1 AND OLD.private = 0 THEN
    DELETE FROM favorite_practice_sets
    WHERE practice_set_id = NEW.id AND user_id != NEW.user_id;
    END IF;
END $$

DELIMITER ;