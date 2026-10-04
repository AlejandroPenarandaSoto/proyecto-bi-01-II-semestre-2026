-- =========================================================
-- MODELO TRANSACCIONAL / OPERACIONAL
-- Empresa de telecomunicaciones
-- =========================================================

DROP DATABASE IF EXISTS telecom;

CREATE DATABASE telecom
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE telecom;



-- 1. REGIONES


CREATE TABLE regiones (
    id_region VARCHAR(10) PRIMARY KEY,
    nombre_region VARCHAR(40) NOT NULL,
    provincia VARCHAR(40) NOT NULL,
    canton VARCHAR(40) NOT NULL,

    CONSTRAINT uq_region
        UNIQUE (nombre_region, provincia, canton)
);



-- 2. CLIENTES


CREATE TABLE clientes (
    id_cliente VARCHAR(15) PRIMARY KEY,
    nombre_cliente VARCHAR(100) NOT NULL,
    segmento VARCHAR(30) NOT NULL,
    id_region VARCHAR(10) NOT NULL,
    fecha_alta DATE NOT NULL,
    fecha_baja DATE NULL,
    nivel_consumo VARCHAR(10) NOT NULL,

    CONSTRAINT fk_cliente_region
        FOREIGN KEY (id_region)
        REFERENCES regiones(id_region),

    CONSTRAINT chk_cliente_fechas
        CHECK (
            fecha_baja IS NULL
            OR fecha_baja >= fecha_alta
        ),

    CONSTRAINT chk_nivel_consumo
        CHECK (
            nivel_consumo IN ('Bajo', 'Medio', 'Alto')
        )
);



-- 3. PLANES


CREATE TABLE planes (
    id_plan VARCHAR(10) PRIMARY KEY,
    nombre_plan VARCHAR(60) NOT NULL UNIQUE
);



-- 4. SERVICIOS


CREATE TABLE servicios (
    id_servicio VARCHAR(10) PRIMARY KEY,
    nombre_servicio VARCHAR(40) NOT NULL UNIQUE
);



-- 5. PLAN_SERVICIO
-- Relación entre planes y servicios


CREATE TABLE plan_servicio (
    id_plan VARCHAR(10) NOT NULL,
    id_servicio VARCHAR(10) NOT NULL,

    PRIMARY KEY (id_plan, id_servicio),

    CONSTRAINT fk_plan_servicio_plan
        FOREIGN KEY (id_plan)
        REFERENCES planes(id_plan),

    CONSTRAINT fk_plan_servicio_servicio
        FOREIGN KEY (id_servicio)
        REFERENCES servicios(id_servicio)
);



-- 6. CONTRATOS

CREATE TABLE contratos (
    id_contrato VARCHAR(20) PRIMARY KEY,
    id_cliente VARCHAR(15) NOT NULL,
    id_plan VARCHAR(10) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NULL,

    CONSTRAINT fk_contrato_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),

    CONSTRAINT fk_contrato_plan
        FOREIGN KEY (id_plan)
        REFERENCES planes(id_plan),

    CONSTRAINT chk_contrato_fechas
        CHECK (
            fecha_fin IS NULL
            OR fecha_fin >= fecha_inicio
        )
);



-- 7. TIPOS DE CONSUMO


CREATE TABLE tipos_consumo (
    id_tipo_consumo VARCHAR(10) PRIMARY KEY,
    nombre_tipo_consumo VARCHAR(30) NOT NULL UNIQUE
);



-- 8. CONSUMOS


CREATE TABLE consumos (
    id_evento VARCHAR(15) PRIMARY KEY,
    id_contrato VARCHAR(20) NOT NULL,
    id_servicio VARCHAR(10) NOT NULL,
    id_tipo_consumo VARCHAR(10) NOT NULL,
    fecha_consumo DATE NOT NULL,

    datos_gb DECIMAL(10,2) NULL,
    minutos DECIMAL(10,2) NULL,
    sms DECIMAL(10,2) NULL,

    CONSTRAINT fk_consumo_contrato
        FOREIGN KEY (id_contrato)
        REFERENCES contratos(id_contrato),

    CONSTRAINT fk_consumo_servicio
        FOREIGN KEY (id_servicio)
        REFERENCES servicios(id_servicio),

    CONSTRAINT fk_consumo_tipo
        FOREIGN KEY (id_tipo_consumo)
        REFERENCES tipos_consumo(id_tipo_consumo),

    CONSTRAINT chk_consumo_datos
        CHECK (
            datos_gb IS NULL
            OR datos_gb >= 0
        ),

    CONSTRAINT chk_consumo_minutos
        CHECK (
            minutos IS NULL
            OR minutos >= 0
        ),

    CONSTRAINT chk_consumo_sms
        CHECK (
            sms IS NULL
            OR sms >= 0
        )
);



-- 9. TIPOS DE INCIDENCIA


CREATE TABLE tipos_incidencia (
    id_tipo_incidencia VARCHAR(10) PRIMARY KEY,
    nombre_tipo_incidencia VARCHAR(60) NOT NULL UNIQUE
);



-- 10. CANALES DE ATENCIÓN

              
CREATE TABLE canales_atencion (
    id_canal VARCHAR(10) PRIMARY KEY,
    nombre_canal VARCHAR(40) NOT NULL UNIQUE
);


  
-- 11. INCIDENCIAS


CREATE TABLE incidencias (
    id_incidencia VARCHAR(15) PRIMARY KEY,
    id_evento VARCHAR(15) NOT NULL UNIQUE,
    id_contrato VARCHAR(20) NOT NULL,
    id_servicio VARCHAR(10) NOT NULL,
    id_tipo_incidencia VARCHAR(10) NOT NULL,
    id_canal VARCHAR(10) NOT NULL,

    estado VARCHAR(20) NOT NULL,
    fecha_apertura DATE NOT NULL,
    fecha_cierre DATE NULL,
    tiempo_resolucion_horas DECIMAL(10,2) NULL,

    CONSTRAINT fk_incidencia_contrato
        FOREIGN KEY (id_contrato)
        REFERENCES contratos(id_contrato),

    CONSTRAINT fk_incidencia_servicio
        FOREIGN KEY (id_servicio)
        REFERENCES servicios(id_servicio),

    CONSTRAINT fk_incidencia_tipo
        FOREIGN KEY (id_tipo_incidencia)
        REFERENCES tipos_incidencia(id_tipo_incidencia),

    CONSTRAINT fk_incidencia_canal
        FOREIGN KEY (id_canal)
        REFERENCES canales_atencion(id_canal),

    CONSTRAINT chk_estado_incidencia
        CHECK (
            estado IN ('Abierta', 'Escalada', 'Resuelta', 'Cerrada')
        ),

    CONSTRAINT chk_incidencia_fechas
        CHECK (
            fecha_cierre IS NULL
            OR fecha_cierre >= fecha_apertura
        ),

    CONSTRAINT chk_tiempo_resolucion
        CHECK (
            tiempo_resolucion_horas IS NULL
            OR tiempo_resolucion_horas >= 0
        )
);



-- 12. FACTURAS
-- Una fila por factura


CREATE TABLE facturas (
    id_factura VARCHAR(15) PRIMARY KEY,
    id_contrato VARCHAR(20) NOT NULL,
    fecha_factura DATE NOT NULL,
    monto_total_crc DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_factura_contrato
        FOREIGN KEY (id_contrato)
        REFERENCES contratos(id_contrato),

    CONSTRAINT chk_factura_monto
        CHECK (
            monto_total_crc >= 0
        )
);



-- 13. DETALLE_FACTURA
-- Una fila por servicio dentro de cada factura


CREATE TABLE detalle_factura (
    id_evento VARCHAR(15) PRIMARY KEY,
    id_factura VARCHAR(15) NOT NULL,
    id_servicio VARCHAR(10) NOT NULL,
    monto_linea_crc DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_detalle_factura
        FOREIGN KEY (id_factura)
        REFERENCES facturas(id_factura),

    CONSTRAINT fk_detalle_servicio
        FOREIGN KEY (id_servicio)
        REFERENCES servicios(id_servicio),

    CONSTRAINT chk_detalle_monto
        CHECK (
            monto_linea_crc >= 0
        )
);



-- 14. CANCELACIONES


CREATE TABLE cancelaciones (
    id_evento VARCHAR(15) PRIMARY KEY,
    id_contrato VARCHAR(20) NOT NULL,
    fecha_cancelacion DATE NOT NULL,
    motivo_cancelacion VARCHAR(100) NULL,

    CONSTRAINT fk_cancelacion_contrato
        FOREIGN KEY (id_contrato)
        REFERENCES contratos(id_contrato)
);


