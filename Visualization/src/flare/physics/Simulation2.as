package flare.physics
{
	import flash.geom.Rectangle;
	
	/**
	 * A physical Simulation2 involving particles, springs, and forces.
	 * Useful for simulating a range of physical effects or layouts.
	 */
	public class Simulation2
	{
		protected var _particles:Array = new Array();
		protected var _springs:Array = new Array();
		protected var _forces:Array = new Array();
		protected var _bounds:Rectangle = null;
		
		/** The default gravity force for this Simulation2. */
		public function get gravityForce():GravityForce {
			return _forces[0] as GravityForce;
		}
		
		/** The default n-body force for this Simulation2. */
		public function get nbodyForce():NBodyForce2 {
			return _forces[1] as NBodyForce2;
		}
		
		/** The default drag force for this Simulation2. */
		public function get dragForce():DragForce {
			return _forces[2] as DragForce;
		}
		
		/** The default spring force for this Simulation2. */
		public function get springForce():SpringForce2 {
			return _forces[3] as SpringForce2;
		}
		
		/** Sets a bounding box for particles in this Simulation2.
		 *  Null (the default) indicates no boundaries. */
		public function get bounds():Rectangle { return _bounds; }
		public function set bounds(b:Rectangle):void {
			if (_bounds == b) return;
			if (b == null) { _bounds = null; return; }
			if (_bounds == null) { _bounds = new Rectangle(); }
			// ensure x is left-most and y is top-most
			_bounds.x = b.x + (b.width < 0 ? b.width : 0);
			_bounds.width = (b.width < 0 ? -1 : 1) * b.width;
			_bounds.y = b.y + (b.width < 0 ? b.height : 0);
			_bounds.height = (b.height < 0 ? -1 : 1) * b.height;
		}
		
		/**
		 * Creates a new physics Simulation2.
		 * @param gx the gravitational acceleration along the x dimension
		 * @param gy the gravitational acceleration along the y dimension
		 * @param drag the default drag (viscosity) co-efficient
		 * @param attraction the gravitational attraction (or repulsion, for
		 *  negative values) between particles.
		 */
		public function Simulation2(gx:Number=0, gy:Number=0,
			drag:Number=0.1, attraction:Number=-5)
		{
			_forces.push(new GravityForce(gx, gy));
			_forces.push(new NBodyForce2(attraction));
			_forces.push(new DragForce(drag));
			_forces.push(new SpringForce2());
		}
		
		// -- Init Simulation2 -------------------------------------------------
		
		/**
		 * Adds a custom force to the force Simulation2.
		 * @param force the force to add
		 */
		public function addForce(force:IForce):void
		{
			_forces.push(force);
		}
		
		/**
		 * Returns the force at the given index.
		 * @param idx the index of the force to look up
		 * @return the force at the specified index
		 */ 
		public function getForceAt(idx:int):IForce
		{
			return _forces[idx];
		}
		
		/**
		 * Adds a new particle to the Simulation2.
		 * @param mass the mass (charge) of the particle
		 * @param x the particle's starting x position
		 * @param y the particle's starting y position
		 * @return the added particle
		 */
		public function addParticle(mass:Number, x:Number, y:Number):Particle2
		{
			var p:Particle2 = getParticle(mass, x, y);
			_particles.push(p);
			return p;
		}
		
		/**
		 * Removes a particle from the Simulation2. Any springs attached to
		 * the particle will also be removed.
		 * @param idx the index of the particle in the particle list
		 * @return true if removed, false otherwise.
		 */
		public function removeParticle(idx:uint):Boolean
		{
			var p:Particle2 = _particles[idx];
			if (p == null) return false;
			
			// remove springs
			for (var i:uint = _springs.length; --i >= 0; ) {
				var s:Spring = _springs[i];
				if (s.p1 == p || s.p2 == p)
					removeSpring(i);
			}
			// remove from particles
			reclaimParticle(p);
			_particles.splice(idx, 1);
			return true;
		}
		
		/**
		 * Adds a spring to the Simulation2
		 * @param p1 the first particle attached to the spring
		 * @param p2 the second particle attached to the spring
		 * @param restLength the rest length of the spring
		 * @param tension the tension of the spring
		 * @param damping the damping (friction) co-efficient of the spring
		 * @return the added spring
		 */
		public function addSpring(p1:Particle2, p2:Particle2, restLength:Number,
							      tension:Number, damping:Number):Spring
		{
			var s:Spring = getSpring(p1, p2, restLength, tension, damping);
			p1.degree++;
			p2.degree++;
			_springs.push(s);
			return s;
		}
		
		
		/**
		 * Removes a spring from the Simulation2.
		 * @param idx the index of the spring in the spring list
		 * @return true if removed, false otherwise
		 */
		public function removeSpring(idx:uint):Boolean
		{
			if (idx >= _springs.length) return false;
			var s:Spring = _springs[idx];
			s.p1.degree--;
			s.p2.degree--;
			reclaimSpring(s);
			_springs.splice(idx, 1);
			return true;
		}
		
		/**
		 * Returns the particle list. This is the same array instance backing
		 * the Simulation2, so edit the array with caution.
		 * @return the particle list
		 */
		public function get particles():Array {
			return _particles;
		}
		
		/**
		 * Returns the spring list. This is the same array instance backing
		 * the Simulation2, so edit the array with caution.
		 * @return the spring list
		 */
		public function get springs():Array {
			return _springs;
		}
		
		// -- Run Simulation2 --------------------------------------------------
		
		/**
		 * Advance the Simulation2 for the specified time interval.
		 * @param dt the time interval to step the Simulation2 (default 1)
		 */
		public virtual function tick(dt:Number=1):void
		{	return;
			var p:Particle2, s:Spring, i:uint, ax:Number, ay:Number;
			var dt1:Number = dt/2, dt2:Number = dt*dt/2;
			
			// remove springs connected to dead particles
			for (i=_springs.length; --i>=0;) {
				s = _springs[i];
				if (s.die || s.p1.die || s.p2.die) {
					s.p1.degree--;
					s.p2.degree--;
					reclaimSpring(s);
					_springs.splice(i, 1);
				}
			}
			
			// update particles using Verlet integration
			for (i=_particles.length; --i>=0;) {
				p = _particles[i];
				p.age += dt;
				if (p.die) { // remove dead particles
					reclaimParticle(p);
					_particles.splice(i, 1);
				} else if (p.fixed) {
					p.vx = p.vy = 0;
				} else {
					ax = p.fx / p.mass; ay = p.fy / p.mass;
					p.x  += p.vx*dt + ax*dt2;
					p.y  += p.vy*dt + ay*dt2;
					p._vx = p.vx + ax*dt1;
					p._vy = p.vy + ay*dt1;
				}
			}
			// evaluate the forces
			eval();
			// update particle velocities
			for (i=_particles.length; --i>=0;) {
				p = _particles[i];
				if (!p.fixed) {
					ax = dt1 / p.mass;
					p.vx = p._vx + p.fx * ax;
					p.vy = p._vy + p.fy * ax;
				}
			}
			
			// enfore bounds
			if (_bounds) enforceBounds();
		}
		
		protected function enforceBounds():void {
			var minX:Number = _bounds.x;
			var maxX:Number = _bounds.x + _bounds.width;
			var minY:Number = _bounds.y;
			var maxY:Number = _bounds.y + _bounds.height;
			
			for each (var p:Particle2 in _particles) {
				if (p.x < minX) {
					p.x = minX; p.vx = 0;
				} else if (p.x > maxX) {
					p.x = maxX; p.vx = 0;
				}
				if (p.y < minY) {
					p.y = minY; p.vy = 0;
				}
				else if (p.y > maxY) {
					p.y = maxY; p.vy = 0;
				}
			}
		}
		
		/**
		 * Evaluates the set of forces in the Simulation2.
		 */
		public virtual function eval():void {
			var i:uint, p:Particle2;
			// reset forces
			for (i=_particles.length; --i >= 0; ) {
				p = _particles[i];
				p.fx = p.fy = 0;
			}
			// collect forces
			for (i=0; i<_forces.length; ++i) {
				if(_forces[i] as SpringForce2 != null)(_forces[i] as SpringForce2).apply2(this);
				if(_forces[i] as NBodyForce2 != null)(_forces[i] as NBodyForce2).apply2(this);
				//IForce(_forces[i]).apply(this);
			}
		}
		
		// -- Particle2 Pool ---------------------------------------------------
		
		/** The maximum number of items stored in a Simulation2 object pool. */
		public static var objectPoolLimit:int = 5000;
		protected static var _ppool:Array = new Array();
		protected static var _spool:Array = new Array();
		
		/**
		 * Returns a particle instance, pulling a recycled particle from the
		 * object pool if available.
		 * @param mass the mass (charge) of the particle
		 * @param x the particle's starting x position
		 * @param y the particle's starting y position
		 * @return a particle instance
		 */
		protected static function getParticle(mass:Number, x:Number, y:Number):Particle2
		{
			if (_ppool.length > 0) {
				var p:Particle2 = _ppool.pop();
				p.init(mass, x, y);
				return p;
			} else {
				return new Particle2(mass, x, y);
			}
		}
		
		/**
		 * Returns a spring instance, pulling a recycled spring from the
		 * object pool if available.
		 * @param p1 the first particle attached to the spring
		 * @param p2 the second particle attached to the spring
		 * @param restLength the rest length of the spring
		 * @param tension the tension of the spring
		 * @param damping the damping (friction) co-efficient of the spring
		 * @return a spring instance
		 */
		protected static function getSpring(p1:Particle2, p2:Particle2,
			restLength:Number, tension:Number, damping:Number):Spring
		{
			if (_spool.length > 0) {
				var s:Spring = _spool.pop();
				s.init(p1, p2, restLength, tension, damping);
				return s;
			} else {
				return new Spring(p1, p2, restLength, tension, damping);
			}
		}
		
		/**
		 * Reclaims a particle, adding it to the object pool for recycling
		 * @param p the particle to reclaim
		 */
		protected static function reclaimParticle(p:Particle2):void
		{
			if (_ppool.length < objectPoolLimit) {
				_ppool.push(p);
			}
		}
		
		/**
		 * Reclaims a spring, adding it to the object pool for recycling
		 * @param s the spring to reclaim
		 */
		protected static function reclaimSpring(s:Spring):void
		{
			if (_spool.length < objectPoolLimit) {
				_spool.push(s);
			}
		}
		
	} // end of class Simulation2
}