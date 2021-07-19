class LedgerModel {
  int id;
  int partyID;
  int vocNo;
  String tType;
  String description;
  int date;
  int debit;
  int credit;
  int ts;
  // int bal;

  LedgerModel({
    this.id,
    this.partyID,
    this.vocNo,
    this.tType,
    this.description,
    this.date,
    this.debit,
    this.credit,
    this.ts
    // this.bal,
  });

  Map<String, dynamic> toMap() {
    // used when inserting data to the database
    return <String, dynamic>{
      "ID": id,
      "PartyID": partyID,
      "VocNo": vocNo,
      "TType": tType,
      "Description": description,
      "Date": date,
      "Debit": debit,
      "Credit": credit,
      "ts": ts
      // "Bal": bal,
    };
  }
}
