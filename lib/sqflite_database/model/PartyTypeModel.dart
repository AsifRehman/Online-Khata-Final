class PartyTypeModel {
  int partyTypeID;
  String partyTypeName;
  String partyGroup;
  int ts;

  PartyTypeModel(
      {this.partyTypeID, this.partyTypeName, this.partyGroup, this.ts});

  Map<String, dynamic> toMap() {
    // used when inserting data to the database
    return <String, dynamic>{
      "partyTypeId": partyTypeID,
      "partyTypeName": partyTypeName,
      "partyGroup": partyGroup,
      "ts": ts
    };
  }
}
