BEGIN

  DELETE FROM MH_HOLDINGS_EXT;

  FOR UPLOAD_ROW IN (SELECT SEQ_ID
                     FROM APEX_COLLECTIONS
                     WHERE COLLECTION_NAME = 'SPREADSHEET_CONTENT')
  LOOP
     APEX_COLLECTION.UPDATE_MEMBER_ATTRIBUTE (
        p_collection_name   => 'SPREADSHEET_CONTENT',
        p_seq               => UPLOAD_ROW.SEQ_ID,
        p_attr_number       => '2',
        p_attr_value        => :P3_PORTFOLIO);
     APEX_COLLECTION.UPDATE_MEMBER_ATTRIBUTE (
        p_collection_name   => 'SPREADSHEET_CONTENT',
        p_seq               => UPLOAD_ROW.SEQ_ID,
        p_attr_number       => '4',
        p_attr_value        => :P3_PRICE_DATE);
  END LOOP;
END;