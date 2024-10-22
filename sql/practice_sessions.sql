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

select * from practice_set where id = 40;