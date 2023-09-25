-- --------------------------------------------------------------------------------------------------
-- Microsoft SQL Server/MySQL�����e�[�u���쐬�X�N���v�g�i���̑��̐��i�ł����X�̕ύX�Ŏg����͂��j
-- adhoc�Ƃ������̃f�[�^�x�[�X�ō쐬����z��ō���Ă��܂��B
-- Microsoft SQL Server�̏ꍇ�̓X�L�[�}�̓f�t�H���g��dbo�ƂȂ�܂��B
-- ���g�p�̊��ɍ��킹�ēK�X�A�ύX���������B
-- --------------------------------------------------------------------------------------------------

use adhoc;

CREATE TABLE bi_calendar(
  DayDate date,
  year int,
  month int,
  quarter_term varchar(50),
  half_year_term varchar(50),
  first_day_of_month date,
  last_day_of_month date,
  day_of_week_short varchar(50),
  day_of_week_long varchar(50),
  month_name_short varchar(50),
  month_name_long varchar(50),
  seq_num int
)
;
