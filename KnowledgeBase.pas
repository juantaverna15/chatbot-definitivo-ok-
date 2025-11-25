{$codepage utf8}

unit KnowledgeBase;

interface

const
  MAXKEYWORDS = 10;

type
  TRegistro = record
    id: integer;
    tema: string;
    keywordCount: integer;
    keywords: array[1..MAXKEYWORDS] of string;
    respuesta: string;
  end;

var
  Base: array[1..100] of TRegistro;
  TotalRegistros: integer;

procedure CargarBase(nombreArchivo: string);

implementation

uses TextUtils;

procedure CargarBase(nombreArchivo: string);
var
  f: Text;
  linea, campo: string;
  posSep, kpos, kwCount: integer;
  idValue, code: integer;
begin
  Assign(f, nombreArchivo);
  Reset(f);
  TotalRegistros := 0;
  while not EOF(f) do
  begin
    ReadLn(f, linea);
    linea := TrimStr(linea);

    if linea <> '' then
    begin
      Inc(TotalRegistros);

      { extraer id }
      posSep := Pos('|', linea);
      campo := TrimStr(Copy(linea, 1, posSep-1));
      Delete(linea, 1, posSep);
      Val(campo, idValue, code);
      if code <> 0 then idValue := 0;
      Base[TotalRegistros].id := idValue;

      { extraer tema }
      posSep := Pos('|', linea);
      campo := TrimStr(Copy(linea, 1, posSep-1));
      Delete(linea, 1, posSep);
      campo := ToLowerCase(RemoveAccents(RemovePunctuation(campo)));
      Base[TotalRegistros].tema := campo;

      { extraer keywords }
      posSep := Pos('|', linea);
      campo := TrimStr(Copy(linea, 1, posSep-1));
      Delete(linea, 1, posSep);

      kwCount := 0;
      while Pos(',', campo) > 0 do
      begin
        kpos := Pos(',', campo);
        Inc(kwCount);
        if kwCount <= MAXKEYWORDS then
          Base[TotalRegistros].keywords[kwCount] :=
            TrimStr(ToLowerCase(RemoveAccents(RemovePunctuation(Copy(campo, 1, kpos-1)))));
        Delete(campo, 1, kpos);
      end;
      Inc(kwCount);
      if kwCount <= MAXKEYWORDS then
        Base[TotalRegistros].keywords[kwCount] :=
          TrimStr(ToLowerCase(RemoveAccents(RemovePunctuation(campo))));
      Base[TotalRegistros].keywordCount := kwCount;

      { extraer respuesta (resto de la línea) }
      Base[TotalRegistros].respuesta := TrimStr(linea);
    end;
  end;
  Close(f);
end;

end.
