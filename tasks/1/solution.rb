SUBSTANCE_TEMPERATURES = {
  'water'   => { melting_point: 0,     boiling_point: 100 },
  'ethanol' => { melting_point: -114,  boiling_point: 78.37 },
  'gold'    => { melting_point: 1064,  boiling_point: 2700 },
  'silver'  => { melting_point: 961.8, boiling_point: 2162 },
  'copper'  => { melting_point: 1085,  boiling_point: 2567 }
}.freeze

def convert_between_temperature_units(degrees, from, to)
  from_celsius(to_celsius(degrees, from), to)
end

def melting_point_of_substance(substance, unit)
  from_celsius(SUBSTANCE_TEMPERATURES[substance][:melting_point], unit)
end

def boiling_point_of_substance(substance, unit)
  from_celsius(SUBSTANCE_TEMPERATURES[substance][:boiling_point], unit)
end

def from_celsius(degrees, to)
  case to
  when 'F' then degrees * 1.8 + 32
  when 'K' then degrees + 273.15
  else degrees
  end
end

def to_celsius(degrees, to)
  case to
  when 'F' then (degrees - 32) / 1.8
  when 'K' then degrees - 273.15
  else degrees
  end
end