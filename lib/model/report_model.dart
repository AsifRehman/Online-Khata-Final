class ReportModel {
  int vocNo;
  String tType;
  String date;
  String desc;
  int debit;
  int credit;
  int totalBalance;

  ReportModel(int vocNo,String tType,String date, String desc, int debit, int credit,int totalBalance) {
    this.vocNo = vocNo;
    this.tType = tType;
    this.date= date;
    this.desc=desc;
    this.debit=debit;
    this.credit=credit;
    this.totalBalance=totalBalance;
  }
}
