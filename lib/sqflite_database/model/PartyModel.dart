class PartyModel {
  int partyID;
  String partyName;
  int partyTypeId;
  int debit;
  int credit;
  int total;
  int ts;

  PartyModel(
      {this.partyID,
      this.partyName,
      this.partyTypeId,
      this.debit,
      this.credit,
      this.total,
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
      "ts": ts
    };
  }
}
