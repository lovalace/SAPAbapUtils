@AbapCatalog.sqlViewName: 'ZCDS_V_AUSP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Parti Karakteristik View'
define view zcds_ddl_ausp as select from mch1
inner join ausp
on mch1.cuobj_bm = ausp.objek
left outer join cabn
on ausp.atinn = cabn.atinn {
key mch1.matnr,
key mch1.charg,
 ausp.objek,
 ausp.atinn,
 cabn.atnam,
 cabn.atfor,
 cabn.anzst,
 cabn.anzdz,
 ausp.atwrt,
 ausp.atflv
}
