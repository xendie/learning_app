INSERT INTO practice_session(user_id, practice_set_id, time_started, time_ended)
VALUES (1, 2, '2024-10-22 15:10:10.000', '2024-10-22 15:15:00.000');

SELECT *, TIMEDIFF(time_ended, time_started) FROM practice_session;

SELECT * FROM practice_set; -- ctrl + enter - execute under cursor
SELECT * FROM practice_set_item WHERE practice_set_id = 1;
SELECT * FROM practice_session_item;


INSERT INTO practice_session_item(practice_session_id, item_id, user_answer, time_started, time_ended)
VALUES (1, 1, );

UPDATE practice_session_item SET
time_started = '2024-10-22 15:13:00.000',
time_ended = '2024-10-22 15:15:00.000'
WHERE id = 4;

select * from practice_session_item;
select * from practice_session;

USE app;

SELECT * FROM practice_session_item WHERE item_id NOT IN (SELECT id FROM practice_set_item);

SELECT * FROM practice_session_item;
SELECT * FROM practice_set_item;

Failed to add the foreign key constraint. Missing unique key for constraint 'fk_practice_session_item_set_item_id' in the referenced table 'practice_set_item'

DELETE FROM practice_set_item WHERE practice_set_id IN (13, 39, 21, 35);

USE app;
SELECT * FROM v_set_questions_all_info WHERE id = 1 AND (private = 0 OR user_id = 1) AND is_deleted = 0;

SELECT id FROM practice_set;
SHOW OPEN TABLES WHERE In_use > 0;

SELECT * FROM practice_set WHERE user_id = 1;

ALTER TABLE practice_set_item
ADD CONSTRAINT question CHECK (question <> '');

SELECT * FROM practice_set_item WHERE question = '' OR answer = '';

SELECT * FROM practice_set WHERE set_name = '';
DELETE FROM practice_set WHERE id = 77;

SELECT id FROM practice_set_item WHERE practice_set_id IN (77, 78, 80, 83, 84, 85);
DELETE FROM practice_set_item WHERE practice_set_id IN (77, 78, 80, 83, 84, 85);


77
78
80
83
84
85

DELETE FROM practice_set WHERE id IN (77, 78);
SELECT * FROM practice_set_item WHERE practice_set_id = 77;

