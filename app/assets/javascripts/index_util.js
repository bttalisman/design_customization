// Utility functions for index pages.



// Get cached array describing all items appearing in the index.  Attempt to
// get it from the session cache, if that doesn't work, get it from the
// html element written by the server.  Cache_name just needs to be unique
// to this index.
function get_cached_json( cache_name )
{
  var array, element, t;

  try {
    array = localStorage.getItem( cache_name );
    array = JSON.parse( array );
  }
  catch (e)
  {
    element = $( '#' + cache_name );
    t = element.text();
    array = JSON.parse( t );
  }

  if( !array ) {
    element = $( '#' + cache_name );
    t = element.text();
    try {
      array = JSON.parse( t );
    }
    catch( e )
    {
      array = [];
    }
  }

  return array;
}

// store the array on the session.  Should be same cache_name as used for
// get_cached_json()
function cache_json( array, cache_name )
{
  var s = JSON.stringify( array );
  localStorage.setItem( cache_name, s );
}


// Save the id and classes string for an arrow element to the session.
function cache_arrow_by_name( e, cache_name )
{
  var id_name = cache_name + '_arrow_id';
  var class_name = cache_name + '_arrow_class';

  localStorage.setItem( id_name, e.attr( 'id' ) );
  localStorage.setItem( class_name, e.attr( 'class' ) );
}



// Get the id and classes of the currently active menu arrow from the sessio,
// hide all arrows, and then show and update the active menu arrow.
function update_arrows( cache_name )
{
  var id_cache_name = cache_name + '_arrow_id';
  var class_cache_name = cache_name + '_arrow_class';

  var id = localStorage.getItem( id_cache_name );
  var classes = localStorage.getItem( class_cache_name );
  hide_arrows();
  var e = $( '#' + id );
  e.show();
  e.attr( 'class', classes );
  e.next().hide();
}

function hide_arrows()
{
  $( '.menu-arrow' ).hide();    // hide arrows
  $( '.arrow-spacer' ).show();  // show all of the arrow spacers
}


function get_arrow_state( e )
{
  return e.hasClass( 'glyphicon-menu-up' );
}

// Flip the specified arrow
function toggle_arrow( e )
{
  hide_arrows();
  e.show();
  e.toggleClass( 'glyphicon-menu-up' );
  e.toggleClass( 'glyphicon-menu-down' );
  e.next().hide();  // hide the arrow spacer immediately following the clicked element.
}


function toggle_header_item( arrow_id, get_function, cache_function, sort_key )
{
  var items = get_function();
  var arrow = $( '#' + arrow_id );
  toggle_arrow( arrow );
  cache_arrow( arrow );

  items.sort( function( obj1, obj2 ) {
    return my_sort( obj1, obj2, sort_key, get_arrow_state( arrow ) ); });
  cache_function( items );

  fill_container();
}



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
  if( (o1[key] !== null) && (o1[key] !== undefined) ) {
    s1 = o1[key].toLowerCase();
    d1 = Date.parse( s1 );
  }

  var s2 = '';
  if( (o2[key] !== null) && (o2[key] !== undefined) ) {
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
