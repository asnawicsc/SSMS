defmodule School do
  @moduledoc """
  School keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  import Ecto.Query
  alias School.Repo
  alias School.Affairs
  alias School.Settings

  alias School.Settings.{
    User,
    Institution
  }

  alias School.Affairs.{
    Absent,
    Semester,
    StudentClass,
    Class,
    Attendance,
    Level,
    Student,
    Parent,
    Teacher,
    Subject,
    SubjectTeachClass,
    StandardSubject,
    ExamMark,
    ExamMaster,
    Exam,
    CoCurriculum,
    Period,
    Timetable
  }

  require IEx

  def races() do
    a = ~s|
AFGHAN
ALBANIA
ALGERIA
ANGOLA
ANTIGUA-BARBUDA
ARAB
ARGENTINA
AUSTRALIA
AUSTRIA
AZERBAIJAN
BADANG
BAH MALI
BAHAMAS
BAHRAIN
BAJAU
BAJAU-SINO
BAKETAN
BAKONG
BALABAK
BALABAK-SINO
BALAU
BANGLADESHI
BANJAR                       
BARBADOS
BATAK
BATANG AI
BATU ELAH
BELARUS
BELGIUM
BELIZE
BELOT
BENIN
BERAWAN
BHUTAN
BIDAYUH ATAU LAND DAYAK
BINADAN
BINTULU
BISAYA
BISAYA
BISAYA-SINO
BOLIVIA
BOLONGAN
BOLONGAN-SINO
BONGOL
BOSNIA_HERZEGOVINA
BOTSWANA
BOYAN                        
BRAZIL
BRITISH
BRUNEI
BRUNEI-SINO
BUGIS                        
BUKET
BULGARIA
BUMIPUTERA SARAWAK
BURMESE
BURUNDI
BUTON
CAMEROON
CANADA
CANTONESE                    
CAPE VERDE
CAUCASIAN
CEYLONESE
CHAD
CHILE
CINA
COCOS
COLOMBIA
COMOROS
COSTA-RICA
CROTIA
CUBA
CYPRUS
DAHOMEY
DALI
DENMARK
DJBOUTI
DOMINICA
DUMPAS
DUSUN
DUSUN
DUSUN-SINO
EL SALVADOR
EQUADOR
EQUATORIAL GUINEA
ETNIK SABAH
ETOPIA
EURASIAN
EUROPEAN
FIJIAN
FILIPINOS
FINLAND
FOOCHOW                      
FRANCE
GABON
GAMBIA
GERMANY
GHANA
GREECE
GRENADA
GUATEMALA
GUINEA
GUINEA_BISSAU
GURKHA
GUYANA
HAINANESE                    
HAITI
HENGHUA                      
HOKCHIA                      
HOKCHIU                      
HOKKIEN                      
HONDURAS
HONG KONG
HUNGARY
HYLAM
IBAN ATAU SEA DAYAK
ICELAND
IDAHAN
IDAHAN-SINO
INDIA
INDIA MUSLIM 
INDONESIA
IRANIAN
IRANUN
IRANUN-SINO
IRAQ
IRELAND
ISRAEL
ITALY
IVORY COAST
JAGOI
JAKUN
JAMAICA
JAPANESE
JAWA                         
JAWI PEKAN                   
JORDAN
KADAZAN
KADAZAN-SINO
KAGAYAN
KAJANG
KANOWIT
KAYAN
KAZAKHSTAN
KEDAYAN
KEDAYAN (SABAH)
KEDAYAN-SINO
KEJAMAN
KELABIT
KEMBOJA
KENYA
KENYAH
KHEK (HAKKA)                 
KHMER
KIMARAGANG
KIRIBATI
KONGFOO
KOREA(UTARA)
KOREAN
KUWAIT
KWIJAU
KWONGSAI                     
KYRGYZ
LAHANAN
LAIN-LAIN
LAIN-LAIN
LAIN-LAIN ASIA/BUKAN WARGANEGARA
LAKIPUT
LAOS
LASAU
LEBANON
LEMANAK
LESOTHO
LIBERIA
LIBYA
LINGKABAU
LIRONG
LISUM ATAU LUGUM
LOGAT
LUNDAYEH
LUNDAYEH-SINO
LUXEMBOURG
MACEDONIA
MADAGASCAR
MALABARI                     
MALAWI
MALAYALI                     
MALDIVES
MALI
MALTESE
MANGKAAK
MANURA
MATAGANG
MATU
MAURITANIA
MAURITIUS
MELAING
MELANAU
MELANAU
MELAYU
MELAYU SABAH
MELAYU SARAWAK
MELAYU SRI LANKA
MELIKIN
MEMALOH
MENADO
MENONDO
MESIR
MEXICO
MIDDLE AFRICA
MINANGKABAU                  
MINOKOK
MIRIEK
MOMOGUN
MONGOLIA
MOROCCO
MOZAMBIQUE
MURUT
MURUT ATAU LUN BAWANG
MURUT-SINO
MYANMAR
NAMIBIA
NAROM
NAURU
NEGRITO
NEPAL
NETHERLAND
NEW ZEALAND
NGURIK
NICARAGUA
NIGERIA
NORWAY
NYAMOK
OMAN
ORANG ASLI (SEMENANJUNG)
ORISSA
PAITAN
PAKISTANI
PALESTIN
PANAMA
PAPUA NEW GUINEA
PARAGUAY
PATHAN
PENAN
PERU
POLAND
PORTUGUESE
PUNAN
PUNJABI                      
QATAR
REPUBLIK CZECH
REPUBLIK SLOVAKIA
ROMANIA
RUMANAU
RUNGUS
RUNGUS-SINO
RUSSIA
RWANDA
SABAN
SAKAI
SAMOA
SAMOA BARAT
SAO TOME &amp; PRINCIPE
SARIBAS
SEBOP
SEBUYAU
SEDUAN
SEGALANG
SEGAN
SEKAPAN
SELAKAN
SELAKO
SEMAI
SEMALAI
SENEGAL
SENOI
SIAM
SIERRA LEONE
SIHAN
SIKH
SINHALESE
SINO-NATIVE
SINULIHAN
SIPENG
SKRANG
SLOVENIA
SOLOMON ISLAND
SOMALIA
SONSONGAN
SOUTH AFRICA
SPAIN
SRI LANKA
SRI LANKA
ST.LUCIA
ST.VINCENT
SUDAN
SULUK
SULUK-SINO
SUNGAI
SUNGAI-SINO
SURINAM
SWAZILAND
SWEDEN
SWITZERLAND
SYCHELLES
SYRIA
TABUN
TAGAL
TAGAL
TAIWAN
TAJIKISTAN
TAMIL                        
TAMIL SRI LANKA
TANJONG
TANZANIA
TATAU
TAUP
TELEGU                       
TELUGU
TEMIAR
TEOCHEW   
THAI
TIADA MAKLUMAT
TIDUNG
TIDUNG
TIDUNG-SINO
TIMOR
TINAGAS
TOGO
TOMBONUO
TONGA
TONGANS
TORAJA
TRING
TRINIDAD DAN TOBAGO
TUNISIA
TURKEY
TURKMENISTAN
TUTONG
TUVALI
UBIAN
UGANDA
UKIT
UKRAINE
ULU AI
UNITED ARAB EMIRATES
UNITED STATES OF AMERICA
UNKOP
UPPER VOLTA
URUGUAY
UZBEKISTAN
VANUATU
VENEZUELA
VIETNAMESE
YEMEN
YUGOSLAVIA
ZAIRE
ZAMBIA
ZIMBABWE
| |> String.split("\n") |> Enum.map(fn x -> String.trim(x) end)
  end

  def fix_gender() do
    existing = ["LELAKI", "PEREMPUAN", "F", "M", "Ｆ", "L", "MALE", "FEMALE", "f", "P"]

    for race <- existing do
      case race do
        "F" ->
          Repo.update_all(from(s in Student, where: s.sex == ^race), set: [sex: "PEREMPUAN"])

        "M" ->
          Repo.update_all(from(s in Student, where: s.sex == ^race), set: [sex: "LELAKI"])

        "Ｆ" ->
          Repo.update_all(from(s in Student, where: s.sex == ^race), set: [sex: "PEREMPUAN"])

        "L" ->
          Repo.update_all(from(s in Student, where: s.sex == ^race), set: [sex: "LELAKI"])

        "MALE" ->
          Repo.update_all(from(s in Student, where: s.sex == ^race), set: [sex: "LELAKI"])

        "FEMALE" ->
          Repo.update_all(from(s in Student, where: s.sex == ^race), set: [sex: "PEREMPUAN"])

        "f" ->
          Repo.update_all(from(s in Student, where: s.sex == ^race), set: [sex: "PEREMPUAN"])

        "P" ->
          Repo.update_all(from(s in Student, where: s.sex == ^race), set: [sex: "PEREMPUAN"])

        _ ->
          Repo.update_all(from(s in Student, where: s.sex == ^race), set: [sex: "LAIN"])
      end
    end
  end

  def fix_race() do
    existing = [
      "C",
      "M",
      "KHEK (HAKKA)                  ",
      "L",
      "1",
      "CANTONESE                     ",
      "HOKKIEN                       ",
      "I",
      "S",
      "2",
      "29",
      "3",
      "TEOCHEW    ",
      "c",
      "F",
      "India",
      "TEOCHEW",
      "KWONGSAI                      ",
      "race",
      "28",
      "Chinese ",
      "Z",
      "Malay",
      "LUNDAYEH",
      "DUSUN",
      "26",
      "25",
      "VIETNAMESE",
      "INDONESIA",
      "SIAM",
      "THAI"
    ]

    for race <- existing do
      case race do
        "S" ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "SIKH"])

        "India" ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "INDIA"])

        "c" ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "CINA"])

        "C" ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "CINA"])

        "KHEK (HAKKA)                  " ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "CINA"])

        "1" ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "CINA"])

        "2" ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "MELAYU"])

        "3" ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "INDIA"])

        "TEOCHEW    " ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "CINA"])

        "TEOCHEW" ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "CINA"])

        "CANTONESE                     " ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "CINA"])

        "HOKKIEN                       " ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "CINA"])

        "Chinese " ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "CINA"])

        "Malay" ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "MELAYU"])

        "M" ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "MELAYU"])

        _ ->
          Repo.update_all(from(s in Student, where: s.race == ^race), set: [race: "LAIN"])
      end
    end
  end

  def assign_rank(list) do
    # list = ["a", "b", "c", "c", "d", "e", "f", "g"]

    Stream.unfold({nil, 1, 0, hd(list), 0}, fn
      nil -> nil
      n -> {n, give_index(n, list)}
    end)
    |> Enum.to_list()
  end

  def give_index(n, list) do
    if List.last(list) == elem(n, 0) do
      nil
    else
      if elem(n, 0) != nil do
        IO.inspect(elem(n, 0))
        IO.puts("total mark prev")
        IO.inspect(elem(n, 0).total_mark)
      end

      IO.puts("total mark next")
      IO.inspect(elem(n, 3).total_mark)

      prev =
        if elem(n, 0) == nil do
          %{total_mark: nil}
        else
          elem(n, 0)
        end

      if prev.total_mark == elem(n, 3).total_mark do
        # if elem(n, 0) == elem(n, 3) do
        next_val = Enum.fetch!(list, elem(n, 2) + 1)
        {elem(n, 3), elem(n, 1), elem(n, 2) + 1, next_val, 1}
      else
        next_val =
          if List.last(list) == elem(n, 3) do
            nil
          else
            Enum.fetch!(list, elem(n, 2) + 1)
          end

        {elem(n, 3), elem(n, 1) + 1 + elem(n, 4), elem(n, 2) + 1, next_val, 0}
      end
    end

    # {cur, index, prev} =
    #   if cur == prev do
    #     index = index
    #     {cur, index, prev}
    #   else
    #     index = index + 1
    #     {cur, index, prev}
    #   end
  end
end
