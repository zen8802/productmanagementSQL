-- --------------------------------------------------------------------------------------------------
-- Microsoft SQL Server/MySQL�����e�[�u���쐬�X�N���v�g�i���̑��̐��i�ł����X�̕ύX�Ŏg����͂��j
-- adhoc�Ƃ������̃f�[�^�x�[�X�ō쐬����z��ō���Ă��܂��B
-- Microsoft SQL Server�̏ꍇ�̓X�L�[�}�̓f�t�H���g��dbo�ƂȂ�܂��B
-- ���g�p�̊��ɍ��킹�ēK�X�A�ύX���������B
-- --------------------------------------------------------------------------------------------------

USE adhoc;

CREATE TABLE sales_orders(
  order_id varchar(50),
  order_date date,
  shopper_id varchar(50),
  product_id varchar(50),
  order_qty int,
  order_amt int
)
;

