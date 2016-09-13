

  function my_sort( obj1, obj2, key, flip )
  {
    var o1, o2;
    var d1, d2;

    if( flip )
    {
      o1 = obj1;
      o2 = obj2;
    }
    else
    {
      o1 = obj2;
      o2 = obj1;
    }

    var s1 = '';
    if( o1[key] !== null ) {
      s1 = o1[key].toLowerCase();
      d1 = Date.parse( s1 );
    }

    var s2 = '';
    if( o2[key] !== null ) {
      s2 = o2[key].toLowerCase();
      d2 = Date.parse( s2 );
    }


    if( d1 && d2 ) {
      s1 = d1;
      s2 = d2;
    }

    var comp;
    if( s1 < s2 )
    {
      comp = -1;
    }
    else if( s1 > s2 )
    {
      comp = 1;
    }
    else
    {
      // the names are equal
      comp = 0;
    }

    return comp;
  }
