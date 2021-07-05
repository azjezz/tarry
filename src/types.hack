namespace Tarry;

type ArchiveNode = shape(
  'filename' => string,
  'content' => string,
  ?'size' => int,
  ?'permissions' => string,
  ?'user_id' => int,
  ?'group_id' => int,
  ?'modification_time' => int,
  ?'checksum' => int,
);
