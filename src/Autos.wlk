import wollok.game.*
import Puntaje.*
import Fondo.*
import Juego.*
import Objetos.*
import GameManager.*
import Musica.*

object audio {

	const audio = game.sound("Audio/motorAuto.wav")

	method reproducir() {
		audio.shouldLoop(true)
		audio.play()
	}

}

object auto {
	var property position = game.at(5, 2)
	var property image = "Autos/player.png"
	var property balas = 10
	const property bloque = new BloqueInvisible(position = self.position().up(1), duenio = self)

	method vertical(sentido) {
		self.position(self.position().up(sentido))
		bloque.position(bloque.position().up(sentido))
	}

	method horizontal(sentido) {
		self.position(self.position().right(sentido))
		bloque.position(bloque.position().right(sentido))
	}

	method soyPlayer() = true

	method image() = image

	method crearContorno() = 0

	method meMori() = vida.cantidad() <= 0

	method chocarCon(algo) {
		algo.choqueConPlayer()
		if (vida.cantidad() <= 0) {
			gameManager.perdio()
		}
	}

	method choqueConPlayer() {
	}

	method disparar() {
		if (balas > 0) {
			self.crearBala(new BalaDePlayer(position = self.position().up(2), coleccion = juego.balasDePlayer()), juego.balasDePlayer())
			balas -= 1
			sonido.reproducir("Audio/balaAuto.wav", 1)
		} else {
			game.say(self, "Encontrá municiones!!")
		}
	}

	method crearBala(bala, coleccion) {
		coleccion.add(bala)
		game.addVisual(bala)
		game.onCollideDo(bala, { algo => bala.leDiA(algo)})
	}

}

object vida {

	var property cantidad = 4
	var property position = game.at(10, 10)

	method image() = "Corazones/corazon" + cantidad.max(0) + ".png"

}

class AutoAzul inherits ObjetoEnLaPista(imagen = "Autos/enemigo1.png", valorXDesaparecer = 5, soyAutoAzul = true) {

	const property bloque = new BloqueInvisible(position = self.position().up(1), duenio = self)

	override method caer() {
		bloque.position(bloque.position().down(1))
		super()
	}

	override method removerObjeto() {
		super()
		game.removeVisual(bloque)
	}

	override method choqueConPlayer() {
		vida.cantidad(vida.cantidad() - 1)
		valorXDesaparecer = -10
		super()
		self.explocion(self.position())
	}

	override method recibirBala(unaBala) {
		self.valorXDesaparecer(25)
		self.removerObjeto()
		unaBala.removerObjeto()
		self.explocion(self.position())
		self.bonif(self.position())
	}

	method explocion(posicion) {
		const explocion = new Explosion(position = posicion, valorXDesaparecer = 0)
		game.addVisual(explocion)
		game.schedule(300, { game.removeVisual(explocion)})
	}

	method bonif(posicion) {
		const bonificacion = new Mas25(position = posicion, imagen = "Puntaje/+25.png", valorXDesaparecer = 0)
		game.addVisual(bonificacion)
		game.schedule(700, { game.removeVisual(bonificacion)})
	}

}

object tanque {

	const property bloques = []
	var property position = game.at(4, 9)
	var valor = 1
	var property vida = 10

	method crearBloques() {
		bloques.add(new BloqueInvisible(position = self.position().up(1).right(1), duenio = self))
		bloques.add(new BloqueInvisible(position = self.position().right(1), duenio = self))
		bloques.add(new BloqueInvisible(position = self.position().up(1), duenio = self))
		bloques.forEach({ bloque => game.addVisual(bloque)})
	}

	method image() = "Autos/tanque.png"

	method choqueConPlayer() {
		gameManager.perdio()
	}

	method chocarCon(algo) {
		if (algo.soyPlayer()) { /*nada*/
		} else algo.choqueConTanque()
	}

	method recibirDanio() {
		self.vida(self.vida() - 1)
		if (self.vida() <= 0) {
			bloques.forEach({bloque=>game.removeVisual(bloque)})
			bloques.clear()
			gameManager.gano()
		}
	}

	method choqueConTanque() {
	}

	method mover() {
		self.position(self.position().right(valor))
		bloques.forEach({ bloque => bloque.position(bloque.position().right(valor))})
		if (self.position().x() <= 2 or self.position().x() >= 8) {
			valor = valor * -1
		}
	}

	method recibirBala(unaBala) {
		unaBala.removerObjeto()
		self.recibirDanio()
	}

	method disparar() {
		if (1.randomUpTo(20) > 10) {
			juego.aparecerEnemigo(new BalaDeTanque(position = self.position().down(1), coleccion = juego.balasDeTanque()), juego.balasDeTanque())
			sonido.reproducir("Audio/balaTanque.wav", 1)
		}
	}

}

