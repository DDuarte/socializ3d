var Viewport = function ( editor, isMobile ) {

	var signals = editor.signals;

	this.container = new UI.Panel();
    var container = this.container;

	var scene = editor.scene;
	var sceneHelpers = editor.sceneHelpers;

	var objects = [];

    var color = 0xffffff;
    var intensity = 1;
    var distance = 0;

    var light = new THREE.PointLight( color, intensity, distance );
    light.name = 'PointLight';

    editor.addObject( light );

	//

	var camera = new THREE.PerspectiveCamera( 50, 1, 1, 5000 );
    camera.position = new THREE.Vector3(-9, 123, 210);
    camera.lookAt(new THREE.Vector3(0, 0, 0));

	var selectionBox = new THREE.BoxHelper();
	selectionBox.material.depthTest = false;
	selectionBox.material.transparent = true;
	selectionBox.visible = false;
	sceneHelpers.add( selectionBox );

	var transformControls = new THREE.TransformControls( camera, container.dom);
	transformControls.addEventListener( 'change', function () {

		controls.enabled = true;

		if ( transformControls.axis !== null ) {

			controls.enabled = false;

		}

                if ( editor.selected !== null ) {

			signals.objectChanged.dispatch( editor.selected );

		}

	} );
	sceneHelpers.add( transformControls );

	// fog

	var oldFogType = "None";
	var oldFogColor = 0xaaaaaa;
	var oldFogNear = 1;
	var oldFogFar = 5000;
	var oldFogDensity = 0.00025;

	// object picking

	var ray = new THREE.Raycaster();
	var projector = new THREE.Projector();

    var opts = {
        lines: 15, // The number of lines to draw
        length: 40, // The length of each line
        width: 10, // The line thickness
        radius: 60,     // The radius of the inner circle
        corners: 1, // Corner roundness (0..1)
        rotate: 40, // The rotation offset
        direction: 1, // 1: clockwise, -1: counterclockwise
        color: '#000', // #rgb or #rrggbb or array of colors
        speed: 1.1, // Rounds per second
        trail: 28, // Afterglow percentage
        shadow: false, // Whether to render a shadow
        hwaccel: false, // Whether to use hardware acceleration
        className: 'spinner', // The CSS class to assign to the spinner
        zIndex: 0, // The z-index (defaults to 2000000000)
        top: '50%', // Top position relative to parent
        left: '50%' // Left position relative to parent
    };

    var spinner = new Spinner(opts).spin();
    container.dom.appendChild(spinner.el);

	var onMouseDownPosition = new THREE.Vector2();
	var onMouseUpPosition = new THREE.Vector2();

	var onMouseDown = function ( event ) {

		event.preventDefault();

		var rect = container.dom.getBoundingClientRect();
		x = (event.clientX - rect.left) / rect.width;
		y = (event.clientY - rect.top) / rect.height;
		onMouseDownPosition.set( x, y );

		document.addEventListener( 'mouseup', onMouseUp, false );

	};

	var onMouseUp = function ( event ) {

		var rect = container.dom.getBoundingClientRect();
		x = (event.clientX - rect.left) / rect.width;
		y = (event.clientY - rect.top) / rect.height;
		onMouseUpPosition.set( x, y );

		if ( onMouseDownPosition.distanceTo( onMouseUpPosition ) == 0 ) {
			render();
		}

		document.removeEventListener( 'mouseup', onMouseUp );

	};

    var onMouseDragged = function(event) {
    };

	var onDoubleClick = function ( event ) {
	};

	container.dom.addEventListener( 'mousedown', onMouseDown, true );
	container.dom.addEventListener( 'dblclick', onDoubleClick, true );
    container.dom.addEventListener('drag', onMouseDragged, true);

	// controls need to be added *after* main logic,
	// otherwise controls.enabled doesn't work.

	var controls = new THREE.EditorControls( camera, container.dom , isMobile);
    controls.center = new THREE.Vector3(0, 0, 0);
	controls.addEventListener( 'change', function () {

		transformControls.update();
		signals.cameraChanged.dispatch( camera );

	} );

    signals.cameraChanged.add(function() {
        light.position = camera.position;
    });

    function onMouseWheel(event) {
        event.preventDefault();
        return false;
    }

    this.activateControls = function (activate) {

        if (activate) {
            container.dom.addEventListener('mousewheel', onMouseWheel, false);
        } else {
            container.dom.removeEventListener('mousewheel', onMouseWheel, false);
        }

        controls.activateControls(activate);
    };

	// signals

	signals.themeChanged.add( function ( value ) {

		switch ( value ) {

			case 'css/light.css':
				//grid.setColors( 0x444444, 0x888888 );
                clearColor = 0xaaaaaa;
				break;
			case 'css/dark.css':
				//grid.setColors( 0xbbbbbb, 0x888888 );
				clearColor = 0x333333;
				break;

		}
		
		renderer.setClearColor( clearColor );

		render();

	} );

	signals.transformModeChanged.add( function ( mode ) {

		transformControls.setMode( mode );

	} );

	signals.snapChanged.add( function ( dist ) {

		transformControls.setSnap( dist );

	} );

	signals.spaceChanged.add( function ( space ) {

		transformControls.setSpace( space );

	} );

	signals.rendererChanged.add( function ( type ) {

		container.dom.removeChild( renderer.domElement );

		renderer = new THREE[ type ]( {
            antialias: true,
            preserveDrawingBuffer   : true   // required to support .toDataURL()
		} );

		renderer.autoClear = false;
		renderer.autoUpdateScene = false;
		renderer.setClearColor( clearColor );
		renderer.setSize( container.dom.offsetWidth, container.dom.offsetHeight );

		container.dom.appendChild( renderer.domElement );

        THREEx.Screenshot.bindKey(renderer);

		render();

	} );

	signals.sceneGraphChanged.add( function () {

		render();
		updateInfo();

	} );

	var saveTimeout;

	signals.cameraChanged.add( function () {

		if ( saveTimeout !== undefined ) {

			clearTimeout( saveTimeout );

		}

		saveTimeout = setTimeout( function () {

			editor.config.setKey( 'camera', {
				position: camera.position.toArray(),
				target: controls.center.toArray()
			} );

		}, 1000 );

		render();

	} );

	signals.objectSelected.add( function ( object ) {
		render();
	} );

	signals.objectAdded.add( function ( object ) {

        spinner.stop();
		var materialsNeedUpdate = false;
        //console.log(object);

		object.traverse( function ( child ) {

			if ( child instanceof THREE.Light ) materialsNeedUpdate = true;

			objects.push( child );

		} );

		if ( materialsNeedUpdate === true ) updateMaterials();

	} );

	signals.objectChanged.add( function ( object ) {

		transformControls.update();

		if ( object !== camera ) {

			if ( object.geometry !== undefined ) {

				selectionBox.update( object );

			}

			if ( editor.helpers[ object.id ] !== undefined ) {

				editor.helpers[ object.id ].update();

			}

			updateInfo();

		}

		render();

	} );

	signals.objectRemoved.add( function ( object ) {

		var materialsNeedUpdate = false;

		object.traverse( function ( child ) {

			if ( child instanceof THREE.Light ) materialsNeedUpdate = true;

			objects.splice( objects.indexOf( child ), 1 );

		} );

		if ( materialsNeedUpdate === true ) updateMaterials();

	} );

	signals.helperAdded.add( function ( object ) {

		objects.push( object.getObjectByName( 'picker' ) );

	} );

	signals.helperRemoved.add( function ( object ) {

		objects.splice( objects.indexOf( object.getObjectByName( 'picker' ) ), 1 );

	} );

	signals.materialChanged.add( function ( material ) {

		render();

	} );

    signals.centroidComputed.add(function(centroid){
        camera.lookAt(centroid);
        camera.center = centroid;
    });

    signals.distanceComputed.add(function(position) {
        camera.position = position;
        controls.rotate(new THREE.Vector3(0.1, 0.1, 0.1));
    });

	signals.fogTypeChanged.add( function ( fogType ) {

		if ( fogType !== oldFogType ) {

			if ( fogType === "None" ) {

				scene.fog = null;

			} else if ( fogType === "Fog" ) {

				scene.fog = new THREE.Fog( oldFogColor, oldFogNear, oldFogFar );

			} else if ( fogType === "FogExp2" ) {

				scene.fog = new THREE.FogExp2( oldFogColor, oldFogDensity );

			}

			updateMaterials();

			oldFogType = fogType;

		}

		render();

	} );

	signals.fogColorChanged.add( function ( fogColor ) {

		oldFogColor = fogColor;

		updateFog( scene );

		render();

	} );

	signals.fogParametersChanged.add( function ( near, far, density ) {

		oldFogNear = near;
		oldFogFar = far;
		oldFogDensity = density;

		updateFog( scene );

		render();

	} );

	signals.windowResize.add( function () {

		camera.aspect = container.dom.offsetWidth / container.dom.offsetHeight;
		camera.updateProjectionMatrix();

		renderer.setSize( container.dom.offsetWidth, container.dom.offsetHeight );

		render();

	} );

	signals.playAnimations.add( function (animations) {
		
		function animate() {

			requestAnimationFrame( animate );
			
			for ( var i = 0; i < animations.length ; i ++ ) {

				animations[i].update(0.016);

			} 

			render();
		}

		animate();

	} );

    if (!isMobile) {
        container.dom.addEventListener('mousewheel', function (event) {
            event.preventDefault();
            return false;
        }, false);
    }

	var clearColor, renderer;

	if ( editor.config.getKey( 'renderer' ) !== undefined ) {

		renderer = new THREE[ editor.config.getKey( 'renderer' ) ]( { antialias: true } );

	} else {

		if ( System.support.webgl === true ) {

			renderer = new THREE.WebGLRenderer( { antialias: true } );

		} else {

			renderer = new THREE.CanvasRenderer();

		}

	}

	renderer.autoClear = false;
	renderer.autoUpdateScene = false;
	container.dom.appendChild( renderer.domElement );
    this.renderer = renderer;
	animate();

	//

	function updateInfo() {

		var objects = 0;
		var vertices = 0;
		var faces = 0;

		scene.traverse( function ( object ) {

			if ( object instanceof THREE.Mesh ) {

				objects ++;

				var geometry = object.geometry;

				if ( geometry instanceof THREE.Geometry ) {

					vertices += geometry.vertices.length;
					faces += geometry.faces.length;

				} else if ( geometry instanceof THREE.BufferGeometry ) {

					vertices += geometry.attributes.position.array.length / 3;

					if ( geometry.attributes.index !== undefined ) {

						faces += geometry.attributes.index.array.length / 3;

					} else {

						faces += geometry.attributes.position.array.length / 9;

					}

				}

			}

		} );

		//info.setValue( 'objects: ' + objects + ', vertices: ' + vertices + ', faces: ' + faces );

	}

	function updateMaterials() {

		editor.scene.traverse( function ( node ) {

			if ( node.material ) {

				node.material.needsUpdate = true;

				if ( node.material instanceof THREE.MeshFaceMaterial ) {

					for ( var i = 0; i < node.material.materials.length; i ++ ) {

						node.material.materials[ i ].needsUpdate = true;

					}

				}

			}

		} );

	}

	function updateFog( root ) {

		if ( root.fog ) {

			root.fog.color.setHex( oldFogColor );

			if ( root.fog.near !== undefined ) root.fog.near = oldFogNear;
			if ( root.fog.far !== undefined ) root.fog.far = oldFogFar;
			if ( root.fog.density !== undefined ) root.fog.density = oldFogDensity;

		}

	}

	function animate() {

		requestAnimationFrame( animate );

	}

	function render() {

		sceneHelpers.updateMatrixWorld();
		scene.updateMatrixWorld();

		renderer.clear();
		renderer.render( scene, camera );

		if ( renderer instanceof THREE.RaytracingRenderer === false ) {

			renderer.render( sceneHelpers, camera );

		}

	}
};
