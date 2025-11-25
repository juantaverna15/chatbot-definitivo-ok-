{$codepage utf8}

unit TextUtils;

interface

const
  MAXTOKENS   = 50;
  MAXLENLEV   = 50;  { longitud máxima que considera Levenshtein }
  STOPCOUNT   = 20;  { cantidad de stopwords definidas }

type
  TTokens = array[1..MAXTOKENS] of string;

function ToLowerCase(s: string): string;
function RemovePunctuation(s: string): string;
function RemoveAccents(s: string): string;
function TrimStr(s: string): string;
procedure Tokenize(s: string; var tokens: TTokens; var count: integer);
function IsStopWord(const w: string): boolean;
function RemoveStopWords(s: string): string;
function LevenshteinDistance(s1, s2: string): integer;

implementation
{funcion auxiliar para comparar dos enteros}
function MinInt(a, b: integer): integer;
begin
  if a < b then MinInt := a else MinInt := b;
end;
{borrar espacios }
function TrimStr(s: string): string;
var 
  i, inicio, fin: integer;
begin
  { Buscar el primer carácter que NO sea un espacio }
  inicio := 1;
  while (inicio <= Length(s)) and (s[inicio] = ' ') do
    Inc(inicio);

  { Buscar el último carácter que NO sea un espacio }
  fin := Length(s);
  while (fin >= inicio) and (s[fin] = ' ') do
    Dec(fin);

  { Si no quedó texto útil, devolver cadena vacía }
  if fin < inicio then
    TrimStr := ''
  else
    TrimStr := Copy(s, inicio, fin - inicio + 1);
end;


function ToLowerCase(s: string): string;
var i: integer;
begin
  for i := 1 to Length(s) do
    if (s[i] >= 'A') and (s[i] <= 'Z') then
      s[i] := Chr(Ord(s[i]) + 32);
  ToLowerCase := s;
end;

function RemoveAccents(s: string): string;
var i: integer; c: char;
begin
  for i := 1 to Length(s) do
  begin
    c := s[i];
    { reemplazos básicos de acentos comunes }
    if (c = 'á') or (c = 'Á') then s[i] := 'a';
    if (c = 'é') or (c = 'É') then s[i] := 'e';
    if (c = 'í') or (c = 'Í') then s[i] := 'i';
    if (c = 'ó') or (c = 'Ó') then s[i] := 'o';
    if (c = 'ú') or (c = 'Ú') then s[i] := 'u';
    if (c = 'ñ') or (c = 'Ñ') then s[i] := 'n';
  end;
  RemoveAccents := s;
end;

function RemovePunctuation(s: string): string;
var i: integer; res: string; ch: char;
begin
  res := '';
  for i := 1 to Length(s) do
  begin
    ch := s[i];
    if (ch in ['a'..'z','A'..'Z','0'..'9',' ']) then
      res := res + ch
    else
      { convertir signos a espacio para evitar pegar palabras }
      res := res + ' ';
  end;
  RemovePunctuation := res;
end;

procedure Tokenize(s: string; var tokens: TTokens; var count: integer);
var i: integer; temp: string;
begin
  s := TrimStr(s);
  count := 0;
  temp := '';
  for i := 1 to Length(s) do
  begin
    if s[i] <> ' ' then
      temp := temp + s[i]
    else
    begin
      if temp <> '' then
      begin
        Inc(count);
        if count <= MAXTOKENS then tokens[count] := temp;
        temp := '';
      end;
    end;
  end;
  if temp <> '' then
  begin
    Inc(count);
    if count <= MAXTOKENS then tokens[count] := temp;
  end;
  if count > MAXTOKENS then count := MAXTOKENS;
end;


function IsStopWord(const w: string): boolean;
const
  stops: array[1..STOPCOUNT] of string =
    ('el','la','los','las','que','para','de','del','un','una',
     'y','o','en','al','es','son','como','sobre','a','por');
var i: integer; encontrado: boolean;
begin
  encontrado := False;
  i := 1;
  while (i <= STOPCOUNT) and (not encontrado) do
  begin
    if w = stops[i] then
      encontrado := True;
    Inc(i);
  end;
  IsStopWord := encontrado;
end;


function RemoveStopWords(s: string): string;
var tokens: TTokens; count, i: integer; res: string;
begin
  Tokenize(s, tokens, count);
  res := '';
  for i := 1 to count do
    if not IsStopWord(tokens[i]) then
      res := res + tokens[i] + ' ';
  RemoveStopWords := TrimStr(res);
end;

function LevenshteinDistance(s1, s2: string): integer;
var i, j, cost: integer;
    a, b: string;
    m: array[0..MAXLENLEV,0..MAXLENLEV] of integer;
begin
  { limitar longitud para no exceder memoria }
  if Length(s1) > MAXLENLEV then a := Copy(s1,1,MAXLENLEV) else a := s1;
  if Length(s2) > MAXLENLEV then b := Copy(s2,1,MAXLENLEV) else b := s2;

  m[0,0] := 0;
  for i := 1 to Length(a) do m[i,0] := i;
  for j := 1 to Length(b) do m[0,j] := j;

  for i := 1 to Length(a) do
    for j := 1 to Length(b) do
    begin
      if a[i] = b[j] then cost := 0 else cost := 1;
      { min de inserción, borrado, sustitución }
      if m[i-1,j] + 1 < m[i,j-1] + 1 then
        m[i,j] := m[i-1,j] + 1
      else
        m[i,j] := m[i,j-1] + 1;
      if m[i-1,j-1] + cost < m[i,j] then
        m[i,j] := m[i-1,j-1] + cost;
    end;

  LevenshteinDistance := m[Length(a),Length(b)];
end;
end.

