-- =========================================================
-- Modelo dimensional - Empresa de Telecomunicaciones
-- Esquema: telecom_dw
-- =========================================================

CREATE DATABASE IF NOT EXISTS telecom_dw
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE telecom_dw;

-- =========================================================
-- 1. DIMENSIONES
-- =========================================================

-- dim_tiempo: un registro por día calendario
CREATE TABLE IF NOT EXISTS dim_tiempo (
    sk_tiempo         INT PRIMARY KEY,                 -- formato AAAAMMDD
    fecha             DATE NOT NULL,
    dia               TINYINT UNSIGNED NOT NULL,
    dia_semana        TINYINT UNSIGNED NOT NULL,        -- 1=lunes ... 7=domingo
    nombre_dia        VARCHAR(15) NOT NULL,
    es_fin_de_semana  BIT NOT NULL,
    semana_anio       TINYINT UNSIGNED NOT NULL,
    mes               TINYINT UNSIGNED NOT NULL,
    nombre_mes        VARCHAR(15) NOT NULL,
    anio_mes          CHAR(7) NOT NULL,
    trimestre         TINYINT UNSIGNED NOT NULL,
    nombre_trimestre  VARCHAR(10) NOT NULL,
    semestre          TINYINT UNSIGNED NOT NULL,
    anio              SMALLINT UNSIGNED NOT NULL
) ENGINE=InnoDB;

-- dim_cliente: un registro por cliente
CREATE TABLE IF NOT EXISTS dim_cliente (
    sk_cliente        INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente        VARCHAR(15) NOT NULL UNIQUE,      -- llave natural, ej. CLI-00001
    segmento          VARCHAR(30) NOT NULL,
    fecha_alta        DATE NOT NULL,
    fecha_baja        DATE NULL,
    antiguedad_meses  INT NOT NULL,
    rango_antiguedad  VARCHAR(20) NOT NULL,
    nivel_consumo     VARCHAR(10) NOT NULL,             -- Bajo, Medio o Alto (viene de la fuente)
    estado_cliente    VARCHAR(15) NOT NULL              -- Activo o Cancelado
) ENGINE=InnoDB;

-- dim_plan: un registro por plan
CREATE TABLE IF NOT EXISTS dim_plan (
    sk_plan           INT AUTO_INCREMENT PRIMARY KEY,
    id_plan           VARCHAR(10) NOT NULL UNIQUE,      -- llave natural, ej. PLN-06
    nombre_plan       VARCHAR(60) NOT NULL,
    tipo_plan         VARCHAR(20) NOT NULL              -- Prepago, Pospago, Empresarial o Corporativo
) ENGINE=InnoDB;

-- dim_servicio: un registro por servicio
CREATE TABLE IF NOT EXISTS dim_servicio (
    sk_servicio       INT AUTO_INCREMENT PRIMARY KEY,
    id_servicio       VARCHAR(10) NOT NULL UNIQUE,      -- llave natural, ej. SRV-01
    nombre_servicio   VARCHAR(40) NOT NULL,
    categoria_servicio VARCHAR(30) NOT NULL
) ENGINE=InnoDB;

-- dim_region: un registro por región/provincia/cantón
CREATE TABLE IF NOT EXISTS dim_region (
    sk_region         INT AUTO_INCREMENT PRIMARY KEY,
    id_region         VARCHAR(10) NOT NULL UNIQUE,      -- llave natural, ej. REG-064
    region            VARCHAR(40) NOT NULL,
    provincia         VARCHAR(40) NOT NULL,
    canton            VARCHAR(40) NOT NULL
) ENGINE=InnoDB;

-- dim_canal_atencion: un registro por canal
CREATE TABLE IF NOT EXISTS dim_canal_atencion (
    sk_canal          INT AUTO_INCREMENT PRIMARY KEY,
    id_canal          VARCHAR(10) NOT NULL UNIQUE,      -- llave natural, ej. CAN-05
    nombre_canal      VARCHAR(100) NOT NULL,
    tipo_canal        VARCHAR(30) NOT NULL              -- Presencial, Telefónico o Digital
) ENGINE=InnoDB;

-- dim_tipo_incidencia: un registro por tipo de incidencia
CREATE TABLE IF NOT EXISTS dim_tipo_incidencia (
    sk_tipo_incidencia INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_incidencia VARCHAR(10) NOT NULL UNIQUE,     -- llave natural, ej. INT-01
    nombre_tipo        VARCHAR(60) NOT NULL,
    categoria_incidencia VARCHAR(30) NOT NULL           -- Técnica, Facturación o Comercial
) ENGINE=InnoDB;

-- dim_tipo_consumo: un registro por tipo de consumo
CREATE TABLE IF NOT EXISTS dim_tipo_consumo (
    sk_tipo_consumo   INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_consumo   VARCHAR(10) NOT NULL UNIQUE,      -- llave natural, ej. TC-01
    nombre_tipo_consumo VARCHAR(30) NOT NULL,           -- Datos, Minutos o SMS
    unidad_medida     VARCHAR(15) NOT NULL              -- GB, min o mensajes
) ENGINE=InnoDB;

-- =========================================================
-- 2. TABLA DE HECHOS (vacía, se carga en el Paso 3)
-- =========================================================

CREATE TABLE IF NOT EXISTS fact_telecomunicaciones (
    id_hecho                    BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_evento_origen            VARCHAR(15) NOT NULL,     -- ej. EVT-000001
    tipo_evento                 VARCHAR(20) NOT NULL,     -- FACTURACION, CONSUMO, INCIDENCIA, CANCELACION

    -- Llaves foráneas (dimensiones)
    sk_cliente                  INT NOT NULL,
    sk_plan                     INT NOT NULL,
    sk_servicio                 INT NULL,                 -- nulo en facturación y cancelación
    sk_region                   INT NOT NULL,
    sk_tiempo                   INT NOT NULL,
    sk_tipo_consumo             INT NULL,                 -- solo aplica a consumo
    sk_tipo_incidencia          INT NULL,                 -- solo aplica a incidencia
    sk_canal                    INT NULL,                 -- solo aplica a incidencia

    -- Medidas
    cantidad_evento              TINYINT NOT NULL DEFAULT 1,
    monto_facturado               DECIMAL(12,2) NULL,      -- solo facturación
    cantidad_consumida            DECIMAL(10,2) NULL,      -- solo consumo
    incidencia_resuelta           TINYINT NULL,             -- solo incidencia (0 o 1)
    tiempo_resolucion_horas       DECIMAL(10,2) NULL,       -- solo incidencia
    antiguedad_cancelacion_meses  INT NULL,                 -- solo cancelación

    INDEX ix_fact_cliente (sk_cliente),
    INDEX ix_fact_plan (sk_plan),
    INDEX ix_fact_servicio (sk_servicio),
    INDEX ix_fact_region (sk_region),
    INDEX ix_fact_tiempo (sk_tiempo),
    INDEX ix_fact_tipo_consumo (sk_tipo_consumo),
    INDEX ix_fact_tipo_incidencia (sk_tipo_incidencia),
    INDEX ix_fact_canal (sk_canal),

    CONSTRAINT fk_fact_cliente FOREIGN KEY (sk_cliente) REFERENCES dim_cliente (sk_cliente),
    CONSTRAINT fk_fact_plan FOREIGN KEY (sk_plan) REFERENCES dim_plan (sk_plan),
    CONSTRAINT fk_fact_servicio FOREIGN KEY (sk_servicio) REFERENCES dim_servicio (sk_servicio),
    CONSTRAINT fk_fact_region FOREIGN KEY (sk_region) REFERENCES dim_region (sk_region),
    CONSTRAINT fk_fact_tiempo FOREIGN KEY (sk_tiempo) REFERENCES dim_tiempo (sk_tiempo),
    CONSTRAINT fk_fact_tipo_consumo FOREIGN KEY (sk_tipo_consumo) REFERENCES dim_tipo_consumo (sk_tipo_consumo),
    CONSTRAINT fk_fact_tipo_incidencia FOREIGN KEY (sk_tipo_incidencia) REFERENCES dim_tipo_incidencia (sk_tipo_incidencia),
    CONSTRAINT fk_fact_canal FOREIGN KEY (sk_canal) REFERENCES dim_canal_atencion (sk_canal)
) ENGINE=InnoDB;

-- Verificación de la estructura (sin cargar datos):
-- SHOW TABLES;
-- SHOW CREATE TABLE fact_telecomunicaciones;
