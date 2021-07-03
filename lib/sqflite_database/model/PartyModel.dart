class PartyModel {
  int partyID;
  String partyName;
  int partyTypeId;
  int debit;
  int credit;
  int total;
  int date;
  String mobile1;
  String mobile2;
  int ts;

  PartyModel(
      {this.partyID,
      this.partyName,
      this.partyTypeId,
      this.debit,
      this.credit,
      this.total,
      this.date,
      this.mobile1,
      this.mobile2,
      this.ts});

  Map<String, dynamic> toMap() {
    // used when inserting data to the database
    return <String, dynamic>{
      "partyID": partyID,
      "partyName": partyName,
      "partyTypeId": partyTypeId,
      "debit": debit,
      "credit": credit,
      "total": total,
      "date": date,
      "mobile1": mobile1,
      "mobile2": mobile2,
      "ts": ts
    };
  }
}
