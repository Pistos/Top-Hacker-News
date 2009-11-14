CREATE TABLE items (
      id     INTEGER PRIMARY KEY
    , title  VARCHAR( 256 ) NOT NULL
    , uri    VARCHAR( 1024 ) NOT NULL
    , uri_hn VARCHAR( 1024 ) NOT NULL
    , score  INTEGER NOT NULL
);
